module Brain
  # The brain's part of a task's brief (Task::Brief, Copy for AI): what's known about its client and
  # its piece of work, so an AI doing the task starts with the context a teammate would have, not
  # all of it. It brings the sections marked always in briefs (Brain::Kind: people, how we work
  # together, to start) and those that bear on the task (they share telling words with its title and
  # description), each cut to a length and the whole to a budget; the newest decisions and any that
  # bear on it; and the open questions, so it knows what isn't known. What it leaves out it names,
  # for show_brain.
  module Brief
    SECTION_LIMIT = 1_200
    BUDGET = 6_000
    DECISIONS_NEWEST = 3
    DECISIONS_MAX = 8
    STOPWORDS = %w[about after again their there these those which while would could should where being other
      under above below between into from with that this have will your what when they them then than also just
      only more most some such very make made task work client please need needs done].to_set.freeze

    module_function

    def for(task)
      words = telling_words("#{task.title} #{Brain::Section.plain_of(task.description)}")
      budget = BUDGET
      parts = [ task.client, task.work ].compact.uniq.filter_map do |subject|
        part = brain_for(subject, words, budget)
        budget -= part.to_s.size
        part
      end
      parts.join("\n\n").presence
    end

    def brain_for(subject, words, budget)
      return if budget <= 200

      kinds = Brain::Kind.for(subject)
      written = Brain::Section.for(subject, kinds: kinds).select(&:written?).reject(&:decisions?)
      chosen, left_out = written.partition { it.kind&.always_in_brief? || bears_on?(it.plain, words) }
      decisions = decisions_for(subject, words)
      questions = Brain::Question.open.where(subject: subject).newest_first.limit(5).to_a
      return if chosen.empty? && decisions.empty? && questions.empty? && left_out.empty?

      lines = [ "## What we know about #{Brain::Subject.name(subject)}" ]
      chosen.each do |section|
        lines << "### #{section.label}#{" (#{section.state_label.downcase})" if section.stale?}\n\n#{cut(section.plain, SECTION_LIMIT)}"
      end
      if decisions.any?
        lines << "### Decisions\n\n" + decisions.map { |decision|
          "- #{decision.decided_on.to_fs(:long)}#{" (#{decision.decided_by})" if decision.decided_by}: #{cut(decision.decision_plain, 300)}" \
            "#{" Why: #{cut(decision.why_plain, 200)}" if decision.why_plain.present?}"
        }.join("\n")
      end
      if questions.any?
        lines << "### Not known yet\n\n" + questions.map { "- #{it.question.squish.truncate(200)}" }.join("\n") +
          "\n\nIf you find out, answer it (answer_brain_question); if you need something else it doesn't say, ask (ask_brain_question)."
      end
      lines << "Also in its brain, not shown here: #{left_out.map(&:label).to_sentence}. Read them with show_brain if they matter." if left_out.any?
      cut(lines.join("\n\n"), budget)
    end

    # The newest few, then any that bear on the task, up to a handful.
    def decisions_for(subject, words)
      all = Brain::Decision.where(subject: subject).newest_first.limit(40).to_a
      (all.first(DECISIONS_NEWEST) + all.drop(DECISIONS_NEWEST).select { bears_on?("#{it.decision_plain} #{it.why_plain}", words) }).first(DECISIONS_MAX)
    end

    # Words worth matching on: five letters or more, not the everyday ones.
    def telling_words(text) = text.downcase.scan(/[[:alpha:]][[:alnum:]]{4,}/).reject { STOPWORDS.include?(it) }.to_set

    # Shares two telling words with the task, or one long one (seven letters or more).
    def bears_on?(text, words)
      shared = telling_words(text) & words
      shared.size >= 2 || shared.any? { it.size >= 7 }
    end

    def cut(text, limit) = text.size > limit ? "#{text[0, limit].rstrip}… (cut; the rest is in its brain)" : text
  end
end
