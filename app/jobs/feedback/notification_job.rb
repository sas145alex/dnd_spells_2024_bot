class Feedback::NotificationJob < ApplicationJob
  def perform(feedback_id)
    feedback = Feedback.find(feedback_id)
    Feedback::Notificator.call(feedback)
  end
end
