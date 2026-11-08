module Brain
  # The brain's pages and actions use the core's layout, and vanish while it's switched off.
  class ApplicationController < ::ApplicationController
    layout "application"

    before_action { head :not_found unless Runwell::Plugins.enabled?(:brain) }

    private
      def set_subject
        @subject = Brain::Subject.find(params[:subject], params[:id]) or raise ActiveRecord::RecordNotFound
      end

      def subject_name = Brain::Subject.name(@subject)
  end
end
