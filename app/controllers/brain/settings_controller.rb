module Brain
  # Settings › Plugins › Brain, for whoever manages settings: the sections brains keep (Brain::Kind):
  # named, ordered, for clients, work or both (and which work types), always in AI briefs or only
  # when they bear on the task; new ones added, ones no longer wanted archived (their text kept).
  class SettingsController < ApplicationController
    allow_staff
    require_permission :manage_settings
    agent_tool :show_brain_settings, on: :show, title: "Show the sections brains keep",
      description: "Each section kind: key, name, hint, order, who has it (clients, work or both, and which work types), whether it always goes into AI briefs, and whether it's archived."
    agent_tool :add_brain_kind, on: :create, title: "Add a section brains keep",
      description: "label (and an optional hint); applies_to: both, client or work; work_labels: the work types that have it (blank: all); always_in_brief: always put it into AI briefs (else only when it bears on the task). Its key comes from the label and never changes.",
      params: { kind: { label: "string!", hint: "string", applies_to: Brain::Kind::APPLIES.keys, work_labels: "string[]", always_in_brief: "boolean" } }, next_tools: %i[show_brain_settings]
    agent_tool :update_brain_kind, on: :update, title: "Change a section brains keep",
      description: "id: the kind (from show_brain_settings). Its name, hint, who has it, whether it's always in briefs; move: up or down; archived: true to stop keeping it (its text stays), false to bring it back.",
      params: { kind: { label: "string", hint: "string", applies_to: Brain::Kind::APPLIES.keys, work_labels: "string[]", always_in_brief: "boolean", archived: "boolean" }, move: %w[up down] },
      next_tools: %i[show_brain_settings]

    def show
      @kinds = Brain::Kind.ordered.to_a
    end

    def create
      kind = Brain::Kind.new(kind_params.merge(position: Brain::Kind.maximum(:position).to_i + 1))
      if kind.save
        redirect_to brain_settings_path, notice: "Brains keep #{kind.label} now."
      else
        redirect_to brain_settings_path, alert: kind.errors.full_messages.to_sentence
      end
    end

    def update
      kind = Brain::Kind.find(params[:id])
      kind.move!(params[:move]) if params[:move].in?(%w[up down])
      attributes = params.key?(:kind) ? kind_params : {}
      archived = params.dig(:kind, :archived)
      attributes = attributes.merge(archived_at: (ActiveModel::Type::Boolean.new.cast(archived) ? (kind.archived_at || Time.current) : nil)) unless archived.nil?
      if attributes.empty? || kind.update(attributes)
        redirect_to brain_settings_path, notice: params[:move] ? "Moved #{kind.label}." : "Saved #{kind.label}."
      else
        redirect_to brain_settings_path, alert: kind.errors.full_messages.to_sentence
      end
    end

    private
      def kind_params = params.expect(kind: [ :label, :hint, :applies_to, :always_in_brief, work_labels: [] ])
  end
end
