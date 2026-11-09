module Brain
  # Questions for a brain: asked (a task for its keeper, or a request) when it doesn't say something
  # that's needed, and answered into a section, which closes the task.
  class QuestionsController < ApplicationController
    allow_staff
    agent_tool :ask_brain_question, on: :create, title: "Ask something a client's or a piece of work's brain doesn't say",
      description: "subject: client or work; id. question: what you need to know; key: the section the answer belongs in, from show_brain (optional). It becomes a task for whoever keeps that brain (or a request, if nobody does); the answer is written into the brain.",
      params: { question: { question: "text!", key: "string" } }, next_tools: %i[show_brain]
    agent_tool :answer_brain_question, on: :answer, title: "Answer a question asked about a brain",
      description: "id: the question (from show_brain). answer: the answer (HTML or plain text); key: the section to write it into (default the one asked about). Written into that section with the question, and its task marked done.",
      params: { answer: { answer: "text!", key: "string" } }, next_tools: %i[show_brain]

    before_action :set_subject, only: :create

    def create
      attributes = params.expect(question: %i[question key])
      text = Brain::Section.plain_of(attributes[:question]).squish
      return redirect_back(fallback_location: brain_subject_path(subject: params[:subject], id: params[:id]), alert: "Write the question.") if text.blank?

      question = Brain::Question.ask!(@subject, text, key: Brain::Kind.find_key(attributes[:key])&.key)
      keeper = question.task&.owner
      redirect_back fallback_location: brain_subject_path(subject: params[:subject], id: params[:id]),
        notice: "Asked#{keeper ? " #{keeper.display_name}" : ": it’s a request anyone can take on"}. The answer goes into #{subject_name}’s brain."
    end

    def answer
      question = Brain::Question.find(params[:id])
      return redirect_back(fallback_location: main_app.task_path(question.task || 0), alert: "That question was answered already.") if question.answered?

      attributes = params.expect(answer: %i[answer key])
      return redirect_back(fallback_location: main_app.root_path, alert: "Write the answer.") if Brain::Section.plain_of(attributes[:answer]).blank?

      section = question.answer!(attributes[:answer], key: Brain::Kind.find_key(attributes[:key])&.key, by: Current.user)
      redirect_back fallback_location: main_app.root_path, notice: "Answered, in #{section.label} of #{Brain::Subject.name(question.subject)}’s brain."
    end
  end
end
