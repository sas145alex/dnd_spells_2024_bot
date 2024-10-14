class BaseTelegramController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::MessageContext
  include Telegram::Bot::UpdatesController::CallbackQueryContext
  include Telegram::Bot::UpdatesController::Session
  include AnswerProcessor

  before_action :initialize_session
  after_action :track_user_activity

  def message(*_args)
    respond_with :message,
      text: "Вы ввели сообщение, но вы не находитесь ни в одном из режимов"
  end

  def callback_query(*_args)
    respond_with :message, text: "default callback answer", reply_markup: {}
  end

  private

  def initialize_session
    session[:_last_activity_at] = Time.current.to_i
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
    new_item = {action: action_name, input_value: input_value}
    old_value << new_item
    new_value = old_value.last(10)
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
