module Brain
  # The decisions log of a client's or a piece of work's brain: a decision added, or one added by
  # mistake removed (its whole history stays in the subject's events).
  class DecisionsController < ApplicationController
    allow_staff
    agent_tool :add_brain_decision, on: :create, title: "Log a decision in a client's or a piece of work's brain",
      description: "subject: client or work; id. decision: what was decided; why; decided_by: who decided (as written: a teammate, someone at the client); decided_on: the date (YYYY-MM-DD, default today); task_id: the task it came from, if any.",
      params: { decision: { decision: "text!", why: "text", decided_by: "string", decided_on: "date", task_id: "integer" } }, next_tools: %i[show_brain]
    agent_tool :remove_brain_decision, on: :destroy, title: "Remove a decision logged by mistake"

    before_action :set_subject, only: :create

    def create
      attributes = params.expect(decision: %i[decision why decided_by decided_on task_id])
      decision = Brain::Decision.new(attributes.merge(subject: @subject, created_by: Current.user.person, decided_on: attributes[:decided_on].presence || Date.current))
      if decision.save
        redirect_back fallback_location: brain_subject_path(subject: params[:subject], id: params[:id]), notice: "Logged the decision in #{subject_name}’s brain."
      else
        redirect_back fallback_location: brain_subject_path(subject: params[:subject], id: params[:id]), alert: decision.errors.full_messages.to_sentence
      end
    end

    def destroy
      decision = Brain::Decision.find(params[:id])
      decision.destroy!
      redirect_back fallback_location: main_app.polymorphic_path(decision.subject), notice: "Removed the decision."
    end
  end
end
