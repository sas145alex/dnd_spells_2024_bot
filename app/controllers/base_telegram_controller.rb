class BaseTelegramController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::MessageContext
  include Telegram::Bot::UpdatesController::CallbackQueryContext
  include Telegram::Bot::UpdatesController::Session
  include AnswerProcessor

  HISTORY_STACK_SIZE = 30

  class << self
    DIRECT_COMMAND_REGEXP = /^(?<command>\/\w+)(?<suffix>@(?<receiver>\w+_bot))?$/

    # NOTE: poller mode -> dispatch does not have third argument
    # NOTE: webhook mode -> dispatch has third argument
    def dispatch(bot, update, request = nil)
      command = update.fetch("message", {}).fetch("text", "")
      matches = command.match(DIRECT_COMMAND_REGEXP) || {}
      receiver = matches[:receiver]

      if receiver.blank?
        super
      elsif receiver == bot.username
        update["message"]["text"] = matches[:command]
        super
      else
        # command for another bot in a chat
        nil
      end
    end
  end

  around_action :set_sentry_context
  before_action :initialize_session

  def my_chat_member(*_args)
    TelegramChat::MemberChangeProcessor.call(payload: payload, bot: bot, chat_id: chat["id"])
  end

  def message(*args)
    if payload.key?("left_chat_participant") || payload.key?("new_chat_participant")
      # when bot added or removed telegram sends two requests with different types
      # such changes handled by #my_chat_member in another request
      return
    end

    if payload.key?("pinned_message")
      return
    end

    if message_from_chat? && bot_has_admin_right_in_chat?
      chat_id = chat["id"].to_i
      TelegramChat::LeaveChat.call(bot: bot, chat_id: chat_id)
      TelegramChat::MarkAsRemoved.call(bot: bot, chat_id: chat_id)
      return
    end

    if message_from_chat?
      text = "Ты ввел сообщение, но я не понимаю твою команду. Пожалуйста, проверь команду или выбери ее в меню слева внизу."
      respond_with :message, text: text
    else
      search!(*args)
    end
  end

  def callback_query(*_args)
    respond_with :message, text: "default callback answer", reply_markup: {}
  end

  private

  def bot_has_admin_right_in_chat?
    client_class = BotRequestJob.client_class
    client = client_class.wrap(bot.id)
    client.async(false) do
      data = bot.get_chat_member(user_id: bot.external_id, chat_id: chat["id"])

      data["ok"] == true && data.dig("result", "status") == "administrator"
    end
  end

  def initialize_session
    session[:_last_activity_at] = Time.current.to_i
  end

  def set_sentry_context
    yield
  rescue => e
    Sentry.configure_scope do |scope|
      scope.set_context("_session", session.to_hash)
      scope.set_context("_payload", payload)
    end
    raise e
  end

  def pop_history_item!
    old_value = session[:history_stack] || []
    new_value = old_value[0..-2]
    update_history(new_value)
    new_value.last
  end

  def remember_history!
    old_value = history
    data = payload.key?("data") ? payload["data"].split(":")[1..].join(":") : nil
    input_value = data || payload["text"] || ""
    action_to_remember = @history_action_name || action_name
    new_item = {action: action_to_remember, input_value: input_value}

    return if new_item == history.last

    old_value << new_item
    new_value = old_value.last(HISTORY_STACK_SIZE)
    session[:history_stack] = new_value
  end

  def history
    session[:history_stack] || []
  end

  def update_history(value)
    session[:history_stack] = value
  end

  def track_user_activity
    Telegram::UserMetricsJob.perform_later(payload)
  end

  def track_chat_activity
    return unless message_from_chat?

    Telegram::ChatMetricsJob.perform_later(payload, chat)
  end

  def message_from_chat?
    user_id = payload.dig("from", "id")
    chat_id = chat["id"]
    user_id.present? && chat_id.present? && (user_id != chat_id)
  end

  def respond_with(type, params)
    params[:parse_mode] ||= "HTML"
    params[:message_thread_id] = payload["message_thread_id"] if payload.key?("message_thread_id")
    super
  end

  def current_user
    @current_user ||= begin
      external_user_id = payload.dig("from", "id")
      username = payload.dig("from", "username")
      chat_id = payload.dig("chat", "id")

      return unless external_user_id

      TelegramUser.find_or_create_by!(external_id: external_user_id.to_i) do |user|
        user.username = username
        user.chat_id = chat_id
      end
    end
  end
end
