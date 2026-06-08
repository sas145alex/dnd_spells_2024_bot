class MessageDelivery < ApplicationRecord
  belongs_to :message_distribution
  belongs_to :recipient, polymorphic: true

  # pending — not attempted yet
  # sent    — Telegram accepted the message
  # failed  — Telegram returned an error (see error_reason)
  enum :status, {
    pending: "pending",
    sent: "sent",
    failed: "failed"
  }, default: "pending"

  # Why a delivery failed. nil while pending/sent.
  enum :error_reason, {
    blocked: "blocked",
    deactivated: "deactivated",
    chat_not_found: "chat_not_found",
    flood_wait: "flood_wait",
    other: "other"
  }, prefix: :error

  def self.ransackable_associations(auth_object = nil)
    %w[message_distribution recipient]
  end
end
