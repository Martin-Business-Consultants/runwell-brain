json.summary "What we know about #{Brain::Subject.name(@subject)}: #{@sections.count(&:written?)} of #{@sections.size} sections written#{", #{@sections.count(&:stale?)} not confirmed lately" if @sections.any?(&:stale?)}"
json.subject agent_ref(@subject)
json.sections @sections do |section|
  json.key section.key
  json.label section.label
  json.body section.plain
  json.confirmed_at section.confirmed_at&.iso8601
  json.confirmed_by section.confirmed_by&.display_name
  json.stale section.stale?
end
