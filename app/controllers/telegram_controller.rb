class TelegramController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::MessageContext
  include Telegram::Bot::UpdatesController::CallbackQueryContext
  include Telegram::Bot::UpdatesController::Session

  after_action :track_user_activity

  def message(*args)
    respond_with :message,
      text: "Вы ввели сообщение, но вы не находитесь ни в одном из режимов"
  end

  def about!
    answer_params = BotCommand::About.call
    respond_with :message, answer_params
  end

  def give_advice!(*args)
    if args.empty?
      save_context("give_advice!")

      respond_with :message,
        text: "Если вы хотите предложить исправление, то напишите нам об этом в следующем сообщении"
    else
      reply_with :message, text: "Принято"
      Telegram::ProcessAdviceJob.perform_later(payload["text"], from: from, message_time: payload["date"])
    end
  end

  def wild_magic!(rand_value = nil, *args)
    answer_params = BotCommand::WildMagic.call(rand_value: rand_value)
    respond_with :message, answer_params
  end

  def roll!(roll_formula = nil, *args)
    answer_params = BotCommand::Roll.call(roll_formula: roll_formula)
    respond_with :message, answer_params
  end

  def roll_formula_callback_query(roll_formula = nil, *args)
    answer_params = BotCommand::Roll.call(roll_formula: roll_formula)
    edit_message :text, answer_params
  end

  def feat!(*args)
    answer_params = BotCommand::Feat.call
    respond_with :message, answer_params
  end

  def feat_callback_query(input_value = nil, *args)
    answer_params = BotCommand::Feat.call(input_value: input_value)
    edit_message :text, answer_params
  end

  def glossary!(*args)
    answer_params = BotCommand::Glossary.call
    respond_with :message, answer_params
  end

  def glossary_callback_query(input_value = nil, *args)
    answer_params = BotCommand::Glossary.call(input_value: input_value)
    edit_message :text, answer_params
  end

  def tool!(*args)
    answer_params = BotCommand::Tool.call
    respond_with :message, answer_params
  end

  def tool_callback_query(input_value = nil, *args)
    answer_params = BotCommand::Tool.call(input_value: input_value)
    edit_message :text, answer_params
  end

  def species!(*args)
    answer_params = BotCommand::Species.call
    respond_with :message, answer_params
  end

  def species_callback_query(input_value = nil, *args)
    answer_params = BotCommand::Species.call(input_value: input_value)
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

    answer_params = BotCommand::Spell.call(payload: payload)
    respond_with :message, answer_params
  end

  def spell_callback_query(spell_gid = nil, *args)
    answer_params = BotCommand::Spell.call(payload: payload, spell_gid: spell_gid)
    respond_with :message, answer_params
    Telegram::SpellMetricsJob.perform_later(spell_gid: spell_gid)
  end

  def callback_query(*args)
    respond_with :message, text: "default callback answer", reply_markup: {}
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

  def track_user_activity
    Telegram::UserMetricsJob.perform_later(payload)
  end
end
