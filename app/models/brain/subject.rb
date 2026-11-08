module Brain
  # Whose brain a route or a note belongs to: a client or a piece of work. A note on a task goes to
  # its work (else its client), and one on a section of work to that work.
  module Subject
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
