module Brain
  # A section brains keep, as the install defines it (Settings › Plugins › Brain): its name and hint,
  # its order, whether clients, work or both have it (and, for work, which types: a service's brain
  # can differ from a project's), and whether it always goes into AI briefs or only when it bears on
  # the task. Its key is set once and never changes, so written sections keep their place; one that's
  # no longer wanted is archived, its sections kept. "decisions" is the decisions log.
  class Kind < ApplicationRecord
    self.table_name = "brain_kinds"

    APPLIES = { "both" => "Clients and work", "client" => "Clients only", "work" => "Work only" }.freeze
    DECISIONS = "decisions"

    validates :label, presence: true, length: { maximum: 60 }
    validates :hint, length: { maximum: 200 }
    validates :key, presence: true, uniqueness: true, format: { with: /\A[a-z][a-z0-9_]*\z/ }
    validates :applies_to, inclusion: { in: APPLIES.keys }

    normalizes :label, with: ->(label) { label.to_s.squish }
    normalizes :hint, with: ->(hint) { hint.to_s.squish.presence }
    normalizes :work_labels, with: ->(labels) { (Array(labels).map(&:to_s) & Brain::Kind.work_labels_known).presence }
    before_validation(on: :create) { self.key ||= label.to_s.parameterize(separator: "_").presence }

    scope :active, -> { where(archived_at: nil) }
    scope :ordered, -> { order(:position, :id) }

    # The install's work types (core 5.9: Work.labels, the types in Settings > Names), else the
    # three every core has.
    def self.work_labels_known = Work.respond_to?(:labels) ? Work.labels : Work::LABELS

    # The types to pick from, in the install's order, with their names: those switched on, plus
    # any this section already names.
    def self.work_label_options(selected = [])
      if defined?(WorkType)
        WorkType.cached.select { !it.archived? || Array(selected).include?(it.key) }.map { [ it.name_one, it.key ] }
      else
        Work::LABELS.map { [ Setting.current.label_name(it), it ] }
      end
    end

    def self.keys = active.ordered.pluck(:key)
    def self.find_key(key) = active.find_by(key: key.to_s)

    # The sections a client's or a piece of work's brain keeps, in order.
    def self.for(subject) = active.ordered.select { it.applies?(subject) }

    def applies?(subject)
      if subject.is_a?(Work)
        applies_to.in?(%w[both work]) && (work_labels.blank? || work_labels.include?(subject.label))
      else
        applies_to.in?(%w[both client])
      end
    end

    def decisions? = key == DECISIONS
    def archived? = archived_at.present?

    # One place up or down among the sections kept, the rest numbered again in order.
    def move!(direction)
      siblings = self.class.active.ordered.to_a
      at = siblings.index(self) or return
      to = direction == "up" ? at - 1 : at + 1
      return unless to.between?(0, siblings.size - 1)

      siblings[at], siblings[to] = siblings[to], siblings[at]
      transaction { siblings.each_with_index { |kind, index| kind.update_column(:position, index) } }
    end
  end
end
