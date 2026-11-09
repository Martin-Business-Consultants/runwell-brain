module Brain
  # Something an agent (or anyone) needed to know about a client or a piece of work that its brain
  # doesn't say. Asking makes a task for the brain's keeper (or a request anyone can take on, without
  # one); answering it writes the answer into a section, with the question, and marks the task done.
  # So the brain fills in its own gaps through the work.
  class Question < ApplicationRecord
    self.table_name = "brain_questions"

    belongs_to :subject, polymorphic: true
    belongs_to :task, optional: true
    belongs_to :asked_by, class_name: "User", optional: true
    belongs_to :answered_by, class_name: "User", optional: true

    validates :question, presence: true, length: { maximum: 1000 }
    validates :key, inclusion: { in: ->(_) { Brain::Kind.pluck(:key) } }, allow_nil: true

    scope :open, -> { where(answered_at: nil) }
    scope :newest_first, -> { order(created_at: :desc) }

    def answered? = answered_at.present?

    def self.ask!(subject, question, key: nil, by: Current.user)
      keeper = Brain::Keeping.keeper_for(subject)
      transaction do
        task = Task.create!(title: "Brain question: #{question.squish.truncate(90)}", source: Current.source == "agent" ? "agent" : "app", owner: keeper,
          description: "<p>#{ERB::Util.h(question)}</p><p>Answer it on this task's page, and the answer goes into #{ERB::Util.h(Brain::Subject.name(subject))}’s brain.</p>",
          **(subject.is_a?(Work) ? { work: subject } : { client: subject }))
        create!(subject: subject, question: question, key: key.presence, task: task, asked_by: by&.person).tap do
          subject.record_event!("brain.asked", payload: { question: question.truncate(200) })
        end
      end
    end

    # The answer into its section (the one asked about, or the one chosen), the task done.
    def answer!(html, key:, by:)
      section = Brain::Section.find_or_initialize_by(subject: subject, key: key.presence || self.key || Brain::Kind.for(subject).first&.key)
      transaction do
        section.append_answer!(self, html, by: by)
        update!(answer: html, answered_by: by&.person, answered_at: Time.current, key: section.key)
        task.update(status: "done") if task && task.status != "done"
      end
      section
    end
  end
end
