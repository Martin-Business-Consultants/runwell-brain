# The six sections every brain had, as the install's own (renamed, reordered, added to or archived
# in Settings › Plugins › Brain from now on). Their keys stay, so every section written keeps its place.
class SeedBrainKinds < ActiveRecord::Migration[8.1]
  KINDS = [
    [ "about", "What it’s about", "Their business, how they make money, and what success looks like for them.", false ],
    [ "people", "People", "Who decides, who influences, and how each likes to be reached.", true ],
    [ "working", "How we work together", "Approvals, budgets, response times, the channels they prefer.", true ],
    [ "unique", "What’s unique", "Quirks, constraints, busy seasons, their words for things.", false ],
    [ "history", "History and landmines", "What went wrong before, and promises made.", false ],
    [ "decisions", "Decisions", "What was decided, when, by whom, and why.", false ]
  ].freeze

  def up
    now = Time.current
    KINDS.each_with_index do |(key, label, hint, always), index|
      next if select_value("SELECT 1 FROM brain_kinds WHERE key = #{connection.quote(key)}")

      execute "INSERT INTO brain_kinds (key, label, hint, position, applies_to, always_in_brief, created_at, updated_at) VALUES " \
        "(#{connection.quote(key)}, #{connection.quote(label)}, #{connection.quote(hint)}, #{index}, 'both', #{always ? 1 : 0}, #{connection.quote(now)}, #{connection.quote(now)})"
    end
  end

  def down
    execute "DELETE FROM brain_kinds WHERE key IN (#{KINDS.map { connection.quote(it.first) }.join(", ")})"
  end
end
