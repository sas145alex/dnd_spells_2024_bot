class Telegram::ChatMetricsJob < ApplicationJob
  def perform(payload = {}, chat = {})
    chat_id = chat.dig("id")

    return unless chat_id

    message_send_at = payload.key?("date") ? Time.at(payload["date"]) : Time.current
    chat = TelegramChat.find_or_create_by!(external_id: chat_id.to_i) do |new_chat|
      new_chat.bot_added_at = Time.current
    end
    chat.transaction do
      chat.bot_removed_at = nil if chat.bot_removed_at.present? && chat.bot_removed_at < message_send_at
      chat.increment(:command_requested_count)
      chat.last_seen_at = [message_send_at, chat.last_seen_at].compact.max
      chat.save!
    end
  end
end
