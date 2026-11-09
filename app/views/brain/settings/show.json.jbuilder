json.summary "#{@kinds.count { !it.archived? }} sections kept: #{@kinds.reject(&:archived?).map(&:label).join(", ")}" \
  "#{"; archived: #{@kinds.select(&:archived?).map(&:label).join(", ")}" if @kinds.any?(&:archived?)}."
json.kinds @kinds do |kind|
  json.extract! kind, :id, :key, :label, :hint, :position, :applies_to, :work_labels, :always_in_brief
  json.archived kind.archived?
  json.decisions_log kind.decisions?
end
