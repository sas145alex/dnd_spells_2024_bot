class Feedback < ApplicationRecord
  validates :message, presence: true

  def notify_later
    return false unless id.present?

    Feedback::NotificationJob.perform_later(id)
  end
end
