keeper = Brain::Keeping.keeper_for(@subject)
decisions = Brain::Decision.where(subject: @subject).newest_first.includes(:task).limit(50)
questions = Brain::Question.open.where(subject: @subject).newest_first.includes(:task)
json.summary "What we know about #{Brain::Subject.name(@subject)}: #{@sections.count(&:written?)} of #{@sections.size} sections written" \
  "#{", #{@sections.count(&:stale?)} not confirmed lately" if @sections.any?(&:stale?)}" \
  "#{"; empty: #{@sections.reject(&:written?).map(&:key).join(", ")}" if @sections.any? { !it.written? }}" \
  "; #{decisions.size} decisions; #{questions.size} open questions#{"; kept by #{keeper.display_name}" if keeper}."
revisions = Brain::Section.revisions_of(@sections, limit: 10)
json.subject agent_ref(@subject)
json.keeper(keeper && { id: keeper.id, name: keeper.display_name })
json.sections @sections do |section|
  json.key section.key
  json.label section.label
  json.body section.plain
  json.state section.state
  json.stale section.stale?
  json.confirmable section.confirmable?
  json.always_in_brief section.kind&.always_in_brief? || false
  json.confirmed_at section.confirmed_at&.iso8601
  json.confirmed_by section.confirmed_by&.display_name
  json.history(revisions.fetch(section.id, []).map { |revision| { revision_id: revision.id, at: revision.created_at.iso8601, by: revision.written_by&.display_name, via: revision.via } })
end
json.decisions decisions do |decision|
  json.id decision.id
  json.decided_on decision.decided_on
  json.decision decision.decision_plain
  json.why decision.why_plain.presence
  json.decided_by decision.decided_by
  json.task(decision.task && agent_ref(decision.task))
end
json.open_questions questions do |question|
  json.id question.id
  json.question question.question
  json.key question.key
  json.task(question.task && agent_ref(question.task))
end
