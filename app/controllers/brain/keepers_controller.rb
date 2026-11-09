module Brain
  # Who keeps a brain: the person a stale section becomes a review task for, and a question goes to.
  class KeepersController < ApplicationController
    allow_staff
    agent_tool :set_brain_keeper, on: :update, title: "Choose who keeps a client's or a piece of work's brain",
      description: "subject: client or work; id; keeper_id: someone on the team (id or name), or blank for nobody. They get a task to review any section that goes stale, and the questions asked about it.",
      params: { keeper_id: "integer" }

    before_action :set_subject

    def update
      keeper = params[:keeper_id].present? ? User.people.active.find(params[:keeper_id]) : nil
      Brain::Keeping.keep!(@subject, keeper)
      redirect_back fallback_location: brain_subject_path(subject: params[:subject], id: params[:id]),
        notice: keeper ? "#{keeper.display_name} keeps #{subject_name}’s brain." : "Nobody keeps #{subject_name}’s brain now."
    end
  end
end
