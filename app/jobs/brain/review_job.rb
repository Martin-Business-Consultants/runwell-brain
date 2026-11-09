module Brain
  # The nightly review of stale sections (Brain::Review), from the core's nightly run.
  class ReviewJob < ApplicationJob
    def perform
      Brain::Review.run if Runwell::Plugins.enabled?(:brain)
    end
  end
end
