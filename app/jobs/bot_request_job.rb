class BotRequestJob < ApplicationJob
  include Telegram::Bot::Async::Job

  retry_on Exception, attempts: 2

  def perform(client_id, *args)
    super
  rescue Telegram::Bot::Forbidden, Telegram::Bot::NotFound => e
    Rails.logger.error(e)
    payload = args[1] || {}
    mark_receiver_as_not_available(payload)
    nil
  rescue Telegram::Bot::Error => e
    if e.message.match?("message thread not found")
      Rails.logger.error(e)
      # do not know why this happens so just drop sending the message
      nil
    elsif e.message.match?("message is not modified")
      Rails.logger.error(e)
      # happens sometimes when clicking return button
      nil
    else
      raise
    end
  end

  def mark_receiver_as_not_available(payload = {})
    chat_id = (payload || {}).stringify_keys["chat_id"]

    return unless chat_id

    TelegramChat::MarkAsRemoved.call(bot: nil, chat_id: chat_id)
    TelegramUser::MarkAsRemoved.call(bot: nil, chat_id: chat_id)
  end
end
