module Brain
  # Add to brain: a note that matters long-term moves into a section of its client's or its work's
  # brain (a task's note goes to its work, else its client), credited to who wrote it.
  class PromotionsController < ApplicationController
    allow_staff
    agent_tool :add_note_to_brain, on: :create, title: "Add a note to a brain",
      description: "note_id: the note; key: the section it belongs in (about, people, working, unique, history or decisions). It's added at the end of that section of its client's or its work's brain, credited to who wrote it.",
      params: { key: Brain::Section::KEYS }

    def create
      note = Note.find(params[:note_id])
      subject = Brain::Subject.for_note(note)
      return redirect_back(fallback_location: main_app.root_path, alert: "That note isn’t on a #{helpers.term(:client).downcase} or a #{helpers.term(:work).downcase}.") unless subject

      section = Brain::Section.find_or_initialize_by(subject: subject, key: params[:key].presence_in(Brain::Section::KEYS) || "about")
      section.append!(note, by: Current.user)
      redirect_back fallback_location: main_app.polymorphic_path(subject), notice: "Added to #{section.label} in #{Brain::Subject.name(subject)}’s brain."
    end
  end
end
