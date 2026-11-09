module Brain
  # One part of a client's or a piece of work's brain: what everyone should know about it, in a
  # few lines of rich text. The table is the plugin's own (brain_sections); its subject (a Client
  # or a Work) and the people are core records, pointed at by id. Which sections a brain has, what
  # they're called and in what order is the install's (Brain::Kind); a section is made the first
  # time it's written, and until then the page shows an empty one.
  #
  # Kept true by people. A section is empty (nothing written yet, or cleared), current (written and
  # confirmed within STALE_AFTER) or stale (written, but nobody's confirmed it since): `state`, the
  # one rule the page, the brief and agents read. Writing it confirms it; Confirm says it still
  # holds, and only a written section can be confirmed; writing it blank clears it, back to empty.
  # Every write keeps a version (Brain::Revision) and goes into its client's or work's history
  # (brain.written, brain.cleared, brain.confirmed), and writing or confirming it closes the
  # review task its keeper was given when it went stale (Brain::Review).
  class Section < ApplicationRecord
    self.table_name = "brain_sections"

    STALE_AFTER = 6.months
    STATES = { "empty" => "Nothing yet", "current" => "Confirmed lately", "stale" => "Not confirmed lately" }.freeze

    # Raises, in words, when there's nothing written to confirm.
    class Refused < StandardError; end

    belongs_to :subject, polymorphic: true
    belongs_to :updated_by, class_name: "User", optional: true
    belongs_to :confirmed_by, class_name: "User", optional: true
    has_many :revisions, -> { newest_first }, class_name: "Brain::Revision", dependent: :delete_all

    validates :key, inclusion: { in: ->(_) { Brain::Kind.pluck(:key) } }, uniqueness: { scope: %i[subject_type subject_id] }

    # Every section of a subject's brain, in the install's order: those written, and new ones for
    # the rest. kinds: the subject's (Brain::Kind.for), when the caller has them.
    def self.for(subject, kinds: Brain::Kind.for(subject))
      written = where(subject: subject).includes(:confirmed_by).index_by(&:key)
      kinds.map { |kind| (written[kind.key] || new(subject: subject, key: kind.key)).tap { it.kind = kind } }
    end

    # The newest versions of these sections, one query for them all: section id → [Revision].
    def self.revisions_of(sections, limit: 20)
      ids = sections.select(&:persisted?).map(&:id)
      return {} if ids.empty?

      Brain::Revision.where(section_id: ids).includes(:written_by).newest_first.group_by(&:section_id).transform_values { it.first(limit) }
    end

    # Plain text of some HTML, for briefs, agents and comparing versions.
    def self.plain_of(html) = Rails::HTML5::FullSanitizer.new.sanitize(html.to_s.gsub(%r{</(p|div|li|h\d)>|<br\s*/?>}i, "\n")).gsub(/\n{3,}/, "\n\n").strip

    attr_writer :kind
    def kind = @kind ||= Brain::Kind.find_by(key: key)

    def label = kind&.label || key.humanize
    def hint = kind&.hint
    def decisions? = key == Brain::Kind::DECISIONS
    def written? = body.present? && plain.present?

    def state
      return "empty" unless written?

      confirmed_at && confirmed_at >= STALE_AFTER.ago ? "current" : "stale"
    end

    def state_label = STATES.fetch(state)
    def stale? = state == "stale"
    def confirmable? = written?

    def plain = self.class.plain_of(body)

    # Writing it is saying it's true now; writing it blank clears it (empty, confirmed by no one).
    # via: how (app, agent, note, answer, restore), kept on its version.
    def write!(html, by:, via: nil)
      person = by&.person
      transaction do
        self.body = html
        if written?
          update!(updated_by: person, confirmed_at: Time.current, confirmed_by: person)
        else
          update!(body: nil, updated_by: person, confirmed_at: nil, confirmed_by: nil)
        end
        revisions.create!(body: body, written_by: person, via: via || (Current.source == "agent" ? "agent" : "app"))
        record!(written? ? "brain.written" : "brain.cleared", via: via)
        close_review! if written?
      end
    end

    def confirm!(by:)
      raise Refused, "#{label} has nothing written yet, so there’s nothing to confirm. Write it first." unless confirmable?

      transaction do
        update!(confirmed_at: Time.current, confirmed_by: by&.person)
        record!("brain.confirmed")
        close_review!
      end
    end

    # A note moved in (Add to brain): its text at the end, with who wrote it and when.
    def append!(note, by:)
      credit = "<p><em>From a note by #{ERB::Util.h(note.author&.display_name || "someone")}, #{note.created_at.to_date.to_fs(:long)}</em></p>"
      write!([ body.presence, credit, note.body ].compact.join, by: by, via: "note")
    end

    # An answer to a question an agent asked (Brain::Question), at the end with the question.
    def append_answer!(question, html, by:)
      credit = "<p><em>#{ERB::Util.h(question.question.truncate(140))}: answered by #{ERB::Util.h(by&.person&.display_name || "someone")}, #{Date.current.to_fs(:long)}</em></p>"
      write!([ body.presence, credit, html ].compact.join, by: by, via: "answer")
    end

    # Puts an earlier version back, as a new version (so the one replaced is kept too).
    def restore!(revision, by:) = write!(revision.body, by: by, via: "restore")

    private
      # Into the client's or work's history (its Event, through the core's verb), so a change shows
      # in its History tab, the changes feed agents catch up on, and webhooks.
      def record!(kind, via: nil)
        subject.record_event!(kind, payload: { section: key, label: label, via: via }.compact)
      end

      def close_review!
        return unless review_task_id

        task = Task.find_by(id: review_task_id)
        task.update(status: "done") if task && task.status != "done"
        update_column(:review_task_id, nil)
      end
  end
end
