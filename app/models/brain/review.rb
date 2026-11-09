module Brain
  # Nightly: each section that's gone stale in a brain with a keeper becomes a task for them ("Review
  # People in Harbor Dental's brain"), on that client or piece of work, unless one is still open.
  # Writing or confirming the section closes it (Section#close_review!). Nobody gets one for a brain
  # without a keeper.
  module Review
    module_function

    def run
      Brain::Section.where.not(body: [ nil, "" ]).where(confirmed_at: [ nil, ...Brain::Section::STALE_AFTER.ago ]).includes(:subject).find_each do |section|
        next unless section.subject && section.stale?
        next if section.review_task_id && Task.where(id: section.review_task_id).where.not(status: "done").exists?

        keeper = Brain::Keeping.keeper_for(section.subject) or next
        task = Task.create!(title: "Review #{section.label} in #{Brain::Subject.name(section.subject)}’s brain", source: "app", owner: keeper,
          description: "<p>Nobody has confirmed it in #{ActiveSupport::Duration.build(Brain::Section::STALE_AFTER).inspect}. Read it on the brain tab; " \
            "write what’s changed, or press Still true. Either closes this.</p>",
          **(section.subject.is_a?(Work) ? { work: section.subject } : { client: section.subject }))
        section.update_column(:review_task_id, task.id)
      end
    end
  end
end
