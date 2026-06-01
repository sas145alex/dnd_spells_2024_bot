class BotRequestJob < ApplicationJob
  include Telegram::Bot::Async::Job

  retry_on Exception, attempts: 2

  def perform(client_id, *args)
    set_sentry_context(args)
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

  # sentry-rails wraps each job in its own Sentry scope, so setting on the
  # global scope here is job-local. Links job-path errors (e.g. empty-text
  # sends) back to the API method and chat that produced them.
  def set_sentry_context(args)
    api_method = args[0]
    params = args[1].is_a?(Hash) ? args[1] : {}
    chat_id = params[:chat_id] || params["chat_id"]

    Sentry.set_tags("telegram.api_method": api_method)
    Sentry.set_user(id: chat_id) if chat_id
  end

  def mark_receiver_as_not_available(payload = {})
    chat_id = (payload || {}).stringify_keys["chat_id"]

    return unless chat_id

    TelegramChat::MarkAsRemoved.call(bot: nil, chat_id: chat_id)
    TelegramUser::MarkAsRemoved.call(bot: nil, chat_id: chat_id)
  end
end
