module Brain
  # Whose brain a route or a note belongs to: a client or a piece of work. A note on a task goes to
  # its work (else its client), and one on a section of work to that work; a note with neither has
  # no brain to go to (for_note nil, promotable? false), so it's never offered Add to brain.
  module Subject
    KINDS = %w[client work].freeze
    # What a note may be on to be added to a brain (read from the note's own columns: no query).
    NOTE_SUBJECTS = %w[Client Work Task ScopeItem].freeze

    # A task with neither a work nor a client (an email from an unmatched sender) has no brain; that's
    # known without a query when the task is already loaded with its notes, else it's offered.
    def self.promotable?(note)
      return false unless note.subject_type.in?(NOTE_SUBJECTS)
      return true unless note.subject_type == "Task" && note.association(:subject).loaded?

      for_note(note).present?
    end

    def self.find(kind, id)
      case kind
      when "client" then Client.find(id)
      when "work" then Work.find_by(ref: id) || Work.find(id)
      end
    end

    def self.for_note(note)
      case note.subject
      when Client, Work then note.subject
      when Task then note.subject.work || note.subject.client
      when ScopeItem then note.subject.work
      end
    end

    def self.kind(subject) = subject.is_a?(Work) ? "work" : "client"
    def self.param(subject) = subject.is_a?(Work) ? subject.ref : subject.id
    def self.name(subject) = subject.is_a?(Work) ? subject.title : subject.name
  end
end
