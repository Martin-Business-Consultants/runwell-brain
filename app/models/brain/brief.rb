module Brain
  # The brain's part of a task's brief (Task::Brief, Copy for AI): what's known about its client
  # and its piece of work, so an AI doing the task starts with the context a teammate would have.
  module Brief
    def self.for(task)
      parts = [ (task.client if task.client), (task.work if task.work) ].compact.filter_map { section_for(it) }
      parts.join("\n\n").presence
    end

    def self.section_for(subject)
      written = Section.for(subject).select(&:written?)
      return if written.empty?

      name = subject.is_a?(Work) ? "#{subject.ref} #{subject.title}" : subject.name
      [ "## What we know about #{name}", *written.map { |section| "### #{section.label}#{" (not confirmed lately)" if section.stale?}\n\n#{section.plain}" } ].join("\n\n")
    end
  end
end
