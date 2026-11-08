module Brain
  # "Still true": a section confirmed as it stands, by whoever looked.
  class ConfirmationsController < ApplicationController
    allow_staff
    agent_tool :confirm_brain_section, on: :create, title: "Confirm a section of a brain still holds",
      description: "subject: client or work; id; key: about, people, working, unique, history or decisions. Says the section is still true, as of now, without changing it."

    before_action :set_subject

    def create
      section = Brain::Section.find_by!(subject: @subject, key: params[:key])
      section.confirm!(by: Current.user)
      redirect_back fallback_location: brain_subject_path(subject: params[:subject], id: params[:id]), notice: "Confirmed #{section.label} for #{subject_name}."
    end
  end
end
