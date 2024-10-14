class Telegram::ProcessFeedbackJob < ApplicationJob
  def perform(payload)
    Feedback::Processor.call(payload)
  end
end
