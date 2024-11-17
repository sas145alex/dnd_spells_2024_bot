class Telegram::UserMetricsJob < ApplicationJob
  def perform(payload = {})
    external_user_id = payload.dig("from", "id")
    username = payload.dig("from", "username")

    return unless external_user_id

    message_send_at = payload.key?("date") ? Time.at(payload["date"]) : Time.current
    user = TelegramUser.find_or_create_by!(external_id: external_user_id.to_i) do |user|
      user.username = username
    end
    user.transaction do
      user.increment(:command_requested_count)
      user.last_seen_at = [message_send_at, user.last_seen_at].compact.max
      user.username = username if username.present? && user.username != username
      user.save!
    end
  end
end
