module Brain
  # One decision about a client or a piece of work, in its brain's decisions log: when, what, why,
  # who decided (a person on the team or at the client, as written) and, optionally, the task it
  # came from. So a decision can be found and quoted, and isn't argued again.
  class Decision < ApplicationRecord
    self.table_name = "brain_decisions"

    belongs_to :subject, polymorphic: true
    belongs_to :task, optional: true
    belongs_to :created_by, class_name: "User", optional: true

    validates :decided_on, :decision, presence: true
    validates :decided_by, length: { maximum: 120 }
    normalizes :decided_by, with: ->(name) { name.to_s.squish.presence }

    scope :newest_first, -> { order(decided_on: :desc, id: :desc) }

    after_create_commit { subject.record_event!("brain.decided", payload: { decision: decision_plain.truncate(200), decided_on: decided_on.iso8601 }) }

    def decision_plain = Brain::Section.plain_of(decision)
    def why_plain = Brain::Section.plain_of(why)
  end
end
