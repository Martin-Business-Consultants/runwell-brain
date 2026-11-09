module Brain
  # Putting an earlier version of a section back (its History): written again as a new version, so
  # the one it replaces is kept too.
  class RevisionsController < ApplicationController
    allow_staff
    agent_tool :restore_brain_section, on: :create, title: "Put an earlier version of a brain section back",
      description: "subject: client or work; id; key: a section's key; revision_id: a version from show_brain's history. Written again as the newest version, so nothing is lost."

    before_action :set_subject

    def create
      section = Brain::Section.find_by!(subject: @subject, key: params[:key])
      revision = section.revisions.find(params[:revision_id])
      section.restore!(revision, by: Current.user)
      redirect_back fallback_location: brain_subject_path(subject: params[:subject], id: params[:id]),
        notice: "#{section.label} for #{subject_name} is back as it was #{helpers.time_ago_in_words(revision.created_at)} ago."
    end
  end
end
