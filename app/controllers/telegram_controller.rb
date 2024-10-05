class TelegramController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::MessageContext
  include Telegram::Bot::UpdatesController::CallbackQueryContext
  include Telegram::Bot::UpdatesController::Session

  before_action :initialize_session
  after_action :track_user_activity
  after_action :remember_history!, except: [:go_back_callback_query]

  def message(*args)
    respond_with :message,
      text: "Вы ввели сообщение, но вы не находитесь ни в одном из режимов"
  end

  def about!
    answer_params = BotCommands::About.call
    respond_with :message, answer_params
  end

  def feedback!(*args)
    if args.empty?
      save_context("feedback!")

      respond_with :message,
        text: "Если вы хотите предложить исправление, то напишите нам об этом в следующем сообщении"
    else
      reply_with :message, text: "Принято"
      Telegram::ProcessFeedbackJob.perform_later(payload["text"], from: from, message_time: payload["date"])
    end
  end

  def wild_magic!(rand_value = nil, *args)
    answer_params = BotCommands::WildMagicSearch.call(rand_value: rand_value)
    respond_with :message, answer_params
  end

  def roll!(roll_formula = nil, *args)
    answer_params = BotCommands::Roll.call(roll_formula: roll_formula)
    respond_with :message, answer_params
  end

  def roll_formula_callback_query(roll_formula = nil, *args)
    answer_params = BotCommands::Roll.call(roll_formula: roll_formula)
    edit_message :text, answer_params
  end

  def feat!(*args)
    answer_params = BotCommands::FeatSearch.call
    respond_with :message, answer_params
  end

  def feat_callback_query(input_value = nil, *args)
    answer_params = BotCommands::FeatSearch.call(input_value: input_value)
    edit_message :text, answer_params
  end

  def class!(*args)
    answer_params = BotCommands::CharacterKlassSearch.call(input_value: nil)
    respond_with :message, answer_params
  end

  def class_callback_query(input_value = nil, *args)
    answer_params = BotCommands::CharacterKlassSearch.call(input_value: input_value)
    edit_message :text, answer_params
  end

  def subclass_callback_query(subklass_gid = nil, *args)
    answer_params = BotCommands::CharacterKlassSearch.call(subklass_gid: subklass_gid)
    edit_message :text, answer_params
  end

  def origin!(*args)
    answer_params = BotCommands::OriginSearch.call
    respond_with :message, answer_params
  end

  def origin_callback_query(input_value = nil, *args)
    answer_params = BotCommands::OriginSearch.call(input_value: input_value)
    edit_message :text, answer_params
  end

  def glossary!(*args)
    answer_params = BotCommands::GlossarySearch.call
    respond_with :message, answer_params
  end

  def glossary_callback_query(input_value = nil, *args)
    answer_params = BotCommands::GlossarySearch.call(input_value: input_value)
    edit_message :text, answer_params
  end

  def tool!(*args)
    answer_params = BotCommands::ToolSearch.call
    respond_with :message, answer_params
  end

  def tool_callback_query(input_value = nil, *args)
    answer_params = BotCommands::ToolSearch.call(input_value: input_value)
    edit_message :text, answer_params
  end

  def equipment!(*args)
    answer_params = BotCommands::EquipmentSearch.call
    respond_with :message, answer_params
  end

  def equipment_callback_query(input_value = nil, *args)
    answer_params = BotCommands::EquipmentSearch.call(input_value: input_value)
    edit_message :text, answer_params
  end

  def species!(*args)
    answer_params = BotCommands::SpeciesSearch.call
    respond_with :message, answer_params
  end

  def species_callback_query(input_value = nil, *args)
    answer_params = BotCommands::SpeciesSearch.call(input_value: input_value)
    edit_message :text, answer_params
  end

  def stop_search!(*args)
    reply_markup = {
      remove_keyboard: true
    }

    respond_with :message,
      text: "Поиск окончен",
      reply_markup: reply_markup
  end

  def spell!(*args)
    save_context("spell!")

    answer_params = BotCommands::SpellSearch.call(payload: payload)
    respond_with :message, answer_params
  end

  def spell_callback_query(spell_gid = nil, *args)
    answer_params = BotCommands::SpellSearch.call(payload: payload, spell_gid: spell_gid)
    respond_with :message, answer_params
    Telegram::SpellMetricsJob.perform_later(spell_gid: spell_gid)
  end

  def callback_query(*args)
    respond_with :message, text: "default callback answer", reply_markup: {}
  end

  def go_back_callback_query(*args)
    history_item = pop_history_item!
    if history_item.present?
      send(history_item[:action], history_item[:input_value])
    else
      respond_with :message, text: "Не найден последний ответ от сервера", reply_markup: {}
    end
  end

  def pick_mention_callback_query(*args)
    mention = Mention.find(args[0].to_i)

    mentionable = mention.another_mentionable.decorate
    text = mentionable.description_for_telegram
    parse_mode = mentionable.parse_mode_for_telegram

    mentions = mentionable.mentions.map do |mention|
      {
        text: mention.another_mentionable.decorate.title,
        callback_data: "pick_mention:#{mention.id}"
      }
    end
    inline_keyboard = mentions.in_groups_of(1, false)
    reply_markup = {inline_keyboard: inline_keyboard}

    respond_with :message,
      text: text,
      reply_markup: reply_markup,
      parse_mode: parse_mode
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
