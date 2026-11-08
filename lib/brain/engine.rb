module Brain
  # What everyone should know about each client and piece of work, in one short page that's kept
  # true (docs/brain.md). It owns its table (brain_sections), points at core records by id, and
  # reaches the core only through the plugin contract. Remove it and Runwell runs as before.
  class Engine < ::Rails::Engine
    # Routes join the app's route set (as brain_*), so the core layout's helpers work.
    initializer "brain.routes" do |app|
      app.routes.append do
        scope "brain", module: "brain", as: "brain" do
          constraints subject: /client|work/ do
            get ":subject/:id", to: "subjects#show", as: :subject
            patch ":subject/:id/:key", to: "sections#update", as: :section
            post ":subject/:id/:key/confirmation", to: "confirmations#create", as: :section_confirmation
          end
          post "notes/:note_id", to: "promotions#create", as: :note_promotion
        end
      end
    end

    # A brain on clients and work, through their load hooks. Never columns on core tables.
    initializer "brain.models" do
      ActiveSupport.on_load(:runwell_client) { has_many :brain_sections, as: :subject, class_name: "Brain::Section", dependent: :delete_all }
      ActiveSupport.on_load(:runwell_work) { has_many :brain_sections, as: :subject, class_name: "Brain::Section", dependent: :delete_all }
    end

    config.to_prepare do
      Runwell::Plugins.register :brain, name: "Brain", version: Brain::VERSION, author: "Martin Business Consultants",
        enabled_by_default: false, requires: ">= 5.1.0", homepage: "https://github.com/Martin-Business-Consultants/runwell-brain",
        description: "What everyone should know about each client and piece of work, in one short page kept true: who decides, how they work, what's unique, what was decided. In every task's brief for AI."
      Runwell::Plugins.slot :client_panel, :brain, "brain/slots/client_panel"
      Runwell::Plugins.slot :work_panel, :brain, "brain/slots/work_panel"
      Runwell::Plugins.slot :note_row, :brain, "brain/slots/note_row"
      Runwell::Plugins.stylesheet :brain, "brain/brain"
      Runwell::Plugins.agent_brief :brain, ->(task, _base_url) { Brain::Brief.for(task) }
    end
  end
end
