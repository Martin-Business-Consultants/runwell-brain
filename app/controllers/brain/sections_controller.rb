module Brain
  # Writing one section of a brain, in place on its tab. Writing it confirms it.
  class SectionsController < ApplicationController
    allow_staff
    agent_tool :write_brain_section, on: :update, title: "Write a section of a client's or a piece of work's brain",
      description: "subject: client or work; id: a client's id or name, a work's ref; key: a section's key, from show_brain (about, people, working… as this install names them). body replaces the section (HTML or plain text), and writing it confirms it; a blank body clears it. Keep it short and current: what a new teammate must know.",
      params: { section: { body: "text!" } }, next_tools: %i[show_brain]

    before_action :set_subject

    def update
      section = Brain::Section.find_or_initialize_by(subject: @subject, key: Brain::Kind.find_key(params[:key])&.key || raise(ActiveRecord::RecordNotFound))
      section.write!(params.expect(section: [ :body ])[:body], by: Current.user)
      redirect_back fallback_location: brain_subject_path(subject: params[:subject], id: params[:id]),
        notice: section.written? ? "Saved #{section.label} for #{subject_name}." : "Cleared #{section.label} for #{subject_name}."
    end
  end
end
