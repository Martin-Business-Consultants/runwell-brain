module Brain
  # One version of a section: its text as written, who wrote it and how (via: app, agent, note,
  # answer, restore). Every write keeps one, so nothing written is lost and any version can be put
  # back. what_changed compares it with the one before, paragraph by paragraph.
  class Revision < ApplicationRecord
    self.table_name = "brain_revisions"

    belongs_to :section, class_name: "Brain::Section"
    belongs_to :written_by, class_name: "User", optional: true

    scope :newest_first, -> { order(created_at: :desc, id: :desc) }

    def plain = Brain::Section.plain_of(body)

    # [[:same | :added | :removed, paragraph], …] against the version before (nil: the first).
    def what_changed(previous)
      old_lines, new_lines = (previous&.plain || "").split(/\n+/), plain.split(/\n+/)
      lcs = Array.new(old_lines.size + 1) { Array.new(new_lines.size + 1, 0) }
      old_lines.each_index.reverse_each do |i|
        new_lines.each_index.reverse_each do |j|
          lcs[i][j] = old_lines[i] == new_lines[j] ? lcs[i + 1][j + 1] + 1 : [ lcs[i + 1][j], lcs[i][j + 1] ].max
        end
      end
      changes, i, j = [], 0, 0
      while i < old_lines.size && j < new_lines.size
        if old_lines[i] == new_lines[j] then changes << [ :same, new_lines[j] ] && (i += 1) && (j += 1)
        elsif lcs[i + 1][j] >= lcs[i][j + 1] then changes << [ :removed, old_lines[i] ] && (i += 1)
        else changes << [ :added, new_lines[j] ] && (j += 1)
        end
      end
      changes + old_lines[i..].map { [ :removed, it ] } + new_lines[j..].map { [ :added, it ] }
    end
  end
end
