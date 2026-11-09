module Brain
  # What a request reads once and every row shares (the plugin contract's rule for row slots; not
  # named Current, which would hide the core's Current inside Brain): the
  # sections a note can be added to, for the note menu in each note.
  class PerRequest < ActiveSupport::CurrentAttributes
    attribute :note_kind_options

    def note_kind_options = super || (self.note_kind_options = Brain::Kind.active.ordered.where.not(key: Brain::Kind::DECISIONS).pluck(:label, :key))
  end
end
