module Brain
  # What everyone should know about each client and piece of work, in one short page that's kept
  # true (docs/brain.md). It owns its table (brain_sections), points at core records by id, and
  # reaches the core only through the plugin contract. Remove it and Runwell runs as before.
  class Engine < ::Rails::Engine
    # Routes join the app's route set (as brain_*), so the core layout's helpers work.
    initializer "brain.routes" do |app|
      app.routes.append do
        scope "brain", module: "brain", as: "brain" do
          constraints subject: Regexp.union(Brain::Subject::KINDS) do
            get ":subject/:id", to: "subjects#show", as: :subject
            patch ":subject/:id/keeper", to: "keepers#update", as: :keeper
            post ":subject/:id/decisions", to: "decisions#create", as: :decisions
            post ":subject/:id/questions", to: "questions#create", as: :questions
            patch ":subject/:id/:key", to: "sections#update", as: :section
            post ":subject/:id/:key/confirmation", to: "confirmations#create", as: :section_confirmation
            post ":subject/:id/:key/revisions/:revision_id/restore", to: "revisions#create", as: :section_restore
          end
          post "notes/:note_id", to: "promotions#create", as: :note_promotion
          delete "decisions/:id", to: "decisions#destroy", as: :decision
          post "questions/:id/answer", to: "questions#answer", as: :question_answer
          get "settings", to: "settings#show", as: :settings
          post "settings/kinds", to: "settings#create", as: :kinds
          patch "settings/kinds/:id", to: "settings#update", as: :kind
        end
      end
    end

    # A brain on clients and work, through their load hooks (gone with them: sections and their
    # versions, decisions, questions, keeper). Never columns on core tables.
    initializer "brain.models" do
      ActiveSupport.on_load(:runwell_client) do
        has_many :brain_sections, as: :subject, class_name: "Brain::Section", dependent: :destroy
        has_many :brain_decisions, as: :subject, class_name: "Brain::Decision", dependent: :delete_all
        has_many :brain_questions, as: :subject, class_name: "Brain::Question", dependent: :delete_all
        has_one :brain_keeping, as: :subject, class_name: "Brain::Keeping", dependent: :delete
      end
      ActiveSupport.on_load(:runwell_work) do
        has_many :brain_sections, as: :subject, class_name: "Brain::Section", dependent: :destroy
        has_many :brain_decisions, as: :subject, class_name: "Brain::Decision", dependent: :delete_all
        has_many :brain_questions, as: :subject, class_name: "Brain::Question", dependent: :delete_all
        has_one :brain_keeping, as: :subject, class_name: "Brain::Keeping", dependent: :delete
      end
      ActiveSupport.on_load(:runwell_task) { has_many :brain_questions, class_name: "Brain::Question", dependent: :nullify }
    end

    config.to_prepare do
      Runwell::Plugins.register :brain, name: "Brain", version: Brain::VERSION, author: "Martin Business Consultants",
        enabled_by_default: false, requires: ">= 6.0.0", homepage: "https://github.com/Martin-Business-Consultants/runwell-brain",
        description: "What everyone should know about each client and piece of work, in one short page kept true: who decides, how they work, what's unique, what was decided. In every task's brief for AI."
      Runwell::Plugins.slot :client_panel, :brain, "brain/slots/client_panel"
      Runwell::Plugins.slot :work_panel, :brain, "brain/slots/work_panel"
      Runwell::Plugins.slot :note_row, :brain, "brain/slots/note_row"
      Runwell::Plugins.slot :task_aside, :brain, "brain/slots/task_aside"
      Runwell::Plugins.slot :task_notice, :brain, "brain/slots/task_notice"
      Runwell::Plugins.settings :brain, "Brain", -> { brain_settings_path if can?(:manage_settings) }
      Runwell::Plugins.nightly :brain, -> { Brain::ReviewJob.perform_later }
      Runwell::Plugins.stylesheet :brain, "brain/brain"
      Runwell::Plugins.agent_brief :brain, ->(task, _base_url) { Brain::Brief.for(task) }
    end
  end
end
