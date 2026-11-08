module Brain
  # One part of a client's or a piece of work's brain: what everyone should know about it, in a
  # few lines of rich text. The table is the plugin's own (brain_sections); its subject (a Client
  # or a Work) and the people are core records, pointed at by id. A section is made the first
  # time it's written; until then the page shows an empty one.
  #
  # Kept true by people: writing a section confirms it, and so does Confirm when it still holds.
  # One nobody has confirmed in STALE_AFTER is stale, and says so.
  class Section < ApplicationRecord
    self.table_name = "brain_sections"

    # The sections every brain has, in order, with what goes in each.
    KINDS = {
      "about" => [ "What it’s about", "Their business, how they make money, and what success looks like for them." ],
      "people" => [ "People", "Who decides, who influences, and how each likes to be reached." ],
      "working" => [ "How we work together", "Approvals, budgets, response times, the channels they prefer." ],
      "unique" => [ "What’s unique", "Quirks, constraints, busy seasons, their words for things." ],
      "history" => [ "History and landmines", "What went wrong before, and promises made." ],
      "decisions" => [ "Decisions", "What was decided, when, by whom, and why." ]
    }.freeze
    KEYS = KINDS.keys.freeze
    STALE_AFTER = 6.months

    belongs_to :subject, polymorphic: true
    belongs_to :updated_by, class_name: "User", optional: true
    belongs_to :confirmed_by, class_name: "User", optional: true

    validates :key, inclusion: { in: KEYS }, uniqueness: { scope: %i[subject_type subject_id] }

    # Every section of a subject's brain, in order: those written, and new ones for the rest.
    def self.for(subject)
      written = where(subject: subject).includes(:confirmed_by).index_by(&:key)
      KEYS.map { |key| written[key] || new(subject: subject, key: key) }
    end

    def label = KINDS.fetch(key).first
    def hint = KINDS.fetch(key).last
    def written? = body.present? && plain.present?
    def stale? = written? && (confirmed_at.nil? || confirmed_at < STALE_AFTER.ago)

    # Plain text, for briefs and agents.
    def plain = Rails::HTML5::FullSanitizer.new.sanitize(body.to_s.gsub(%r{</(p|div|li|h\d)>|<br\s*/?>}i, "\n")).gsub(/\n{3,}/, "\n\n").strip

    # Writing it is saying it's true now.
    def write!(html, by:)
      update!(body: html, updated_by: by&.person, confirmed_at: Time.current, confirmed_by: by&.person)
    end

    def confirm!(by:)
      update!(confirmed_at: Time.current, confirmed_by: by&.person)
    end

    # A note moved in (Add to brain): its text at the end, with who wrote it and when.
    def append!(note, by:)
      credit = "<p><em>From a note by #{ERB::Util.h(note.author&.display_name || "someone")}, #{note.created_at.to_date.to_fs(:long)}</em></p>"
      write!([ body.presence, credit, note.body ].compact.join, by: by)
    end
  end
end
