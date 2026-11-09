module Brain
  # A client's or a piece of work's brain, for agents (the page itself is the record's Brain tab).
  class SubjectsController < ApplicationController
    allow_staff
    agent_tool :show_brain, on: :show, title: "Read what everyone should know about a client or a piece of work",
      description: "subject: client or work; id: a client's id or name, a work's ref. Each section (as this install keeps them) as text with its state (empty, current or stale), whether it's always in briefs and its recent versions; the decisions log; the open questions; who keeps it. Read it before working on something for them."

    before_action :set_subject

    def show
      @sections = Brain::Section.for(@subject)
      respond_to do |format|
        format.json
        format.html { redirect_to @subject.is_a?(Work) ? main_app.work_path(@subject, tab: "plugin-brain") : main_app.client_path(@subject, tab: "plugin-brain") }
      end
    end
  end
end
