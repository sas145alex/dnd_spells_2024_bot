class MessageDistribution < ApplicationRecord
  include WhoDidItable

  # draft   — created, not sent yet (the only state from which it can be sent)
  # queued  — audience materialized, delivery job enqueued
  # sending — delivery job is processing recipients
  # completed — every recipient has a final delivery status
  enum :status, {
    draft: "draft",
    queued: "queued",
    sending: "sending",
    completed: "completed"
  }, default: "draft"

  has_many :deliveries, class_name: "MessageDelivery", dependent: :destroy

  validates :title, presence: true
  validates :title, length: {minimum: 3, maximum: 250}, allow_blank: true
  validates :content, presence: true
  validates :content,
    length: {minimum: 5, maximum: 5000},
    allow_blank: true

  before_validation :strip_title

  def self.ransackable_associations(auth_object = nil)
    %w[created_by updated_by deliveries]
  end

  def long_description?
    content.size >= DESCRIPTION_LIMIT
  end

  def sendable?
    draft?
  end

  def start_sending!
    update!(status: :sending, started_at: started_at || Time.current)
  end

  def complete!
    update!(status: :completed, finished_at: Time.current)
  end

  def refresh_counts!
    update!(
      delivered_count: deliveries.sent.count,
      failed_count: deliveries.failed.count
    )
  end

  # Telegram message body — the Markdown-rendered content only. The title is an
  # internal admin label and is not sent to recipients.
  def telegram_text
    FormatChanger.markdown_to_telegram_markdown(content)
  end

  private

  def strip_title
    self.title = title&.strip
  end
end
