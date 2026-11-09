module Brain
  # Who keeps a client's or a piece of work's brain (brain_subjects): the person a stale section
  # becomes a review task for (Brain::Review) and a question goes to (Brain::Question). None means
  # nobody gets those; questions then arrive as requests anyone can take on.
  class Keeping < ApplicationRecord
    self.table_name = "brain_subjects"

    belongs_to :subject, polymorphic: true
    belongs_to :keeper, class_name: "User", optional: true

    def self.keeper_for(subject) = find_by(subject: subject)&.keeper&.then { it if it.active? }

    def self.keep!(subject, keeper)
      find_or_initialize_by(subject: subject).tap { it.update!(keeper: keeper) }
      subject.record_event!("brain.keeper", payload: { keeper: keeper&.display_name }.compact)
    end
  end
end
