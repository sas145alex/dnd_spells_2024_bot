class BaseTelegramController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::MessageContext
  include Telegram::Bot::UpdatesController::CallbackQueryContext
  include Telegram::Bot::UpdatesController::Session
  include AnswerProcessor

  HISTORY_STACK_SIZE = 30

  around_action :set_sentry_context
  before_action :initialize_session
  after_action :track_user_activity

  def message(*_args)
    text = "Ты ввел сообщение, но я не понимаю твою команду. Пожалуйста, проверь команду или выбери ее в меню слева внизу."
    respond_with :message, text: text
  end

  def callback_query(*_args)
    respond_with :message, text: "default callback answer", reply_markup: {}
  end

  private

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
end
