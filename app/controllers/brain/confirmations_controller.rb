module Brain
  # "Still true": a section confirmed as it stands, by whoever looked.
  class ConfirmationsController < ApplicationController
    allow_staff
    agent_tool :confirm_brain_section, on: :create, title: "Confirm a section of a brain still holds",
      description: "subject: client or work; id; key: a section's key, from show_brain (about, people, working… as this install names them). Says the section is still true, as of now, without changing it. Only a written one can be confirmed: write_brain_section first."

    before_action :set_subject

    def create
      key = Brain::Kind.find_key(params[:key])&.key or raise ActiveRecord::RecordNotFound
      section = Brain::Section.find_or_initialize_by(subject: @subject, key: key)
      back = brain_subject_path(subject: params[:subject], id: params[:id])
      return redirect_back(fallback_location: back, alert: "#{section.label} for #{subject_name} has nothing written yet, so there’s nothing to confirm. Write it first.") unless section.confirmable?

      section.confirm!(by: Current.user)
      redirect_back fallback_location: back, notice: "Confirmed #{section.label} for #{subject_name}."
    end
  end
end
