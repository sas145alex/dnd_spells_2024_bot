class TelegramController < BaseTelegramController
  after_action :remember_history!, except: [:go_back_callback_query, :pick_mention_callback_query]

  def spell!(*_args)
    save_context("spell!")

    answer_params = BotCommands::SpellSearch.call(payload: payload)
    respond_with :message, answer_params
  end

  def spell_callback_query(spell_gid = nil, *_args)
    answer_params = BotCommands::SpellSearch.call(payload: payload, spell_gid: spell_gid)
    respond_with :message, answer_params
    Telegram::SpellMetricsJob.perform_later(spell_gid: spell_gid)
  end

  def about!
    answer_params = BotCommands::About.call
    respond_with :message, answer_params
  end

  def feedback!(*_args)
    if Feedback.payload_can_be_accepted?(payload)
      reply_with :message, text: "Принято"
      Feedback.create_later(payload)
    else
      save_context("feedback!")

      respond_with :message,
        text: "Если вы хотите предложить исправление или связаться с нами, то напишите нам об этом в следующем сообщении (файлы не поддерживаются)"
    end
  end

  def wild_magic!(rand_value = nil, *_args)
    answer_params = BotCommands::WildMagicSearch.call(rand_value: rand_value)
    respond_with :message, answer_params
  end

  def roll!(input_value = nil, *_args)
    answer_messages = BotCommands::Roll.call(input_value: input_value, manual_input: true)
    process_answer_messages(answer_messages)
  end

  def roll_callback_query(input_value = nil, *_args)
    answer_messages = BotCommands::Roll.call(input_value: input_value)
    process_answer_messages(answer_messages)
  end

  def sections!(*_args)
    answer_messages = BotCommands::Sections.call(input_value: nil)
    process_answer_messages(answer_messages)
  end

  def roll_page_callback_query(page = nil, *_args)
    answer_messages = BotCommands::Roll.call(input_value: nil, page: page.to_i)
    process_answer_messages(answer_messages)
  end

  def feat_callback_query(input_value = nil, *_args)
    answer_params = BotCommands::FeatSearch.call(input_value: input_value)
    edit_message :text, answer_params
  end

  def class_callback_query(input_value = nil, *_args)
    answer_params = BotCommands::CharacterKlassSearch.call(input_value: input_value)
    edit_message :text, answer_params
  end

  def subclass_callback_query(subklass_gid = nil, *_args)
    answer_params = BotCommands::CharacterKlassSearch.call(subklass_gid: subklass_gid)
    edit_message :text, answer_params
  end

  def abilities_callback_query(input_value = nil, *_args)
    answer_params = BotCommands::CharacterKlassAbilitiesSearch.call(input_value: input_value)
    edit_message :text, answer_params
  end

  def invocations_callback_query(input_value = nil, *_args)
    answer_params = BotCommands::InvocationsSearch.call(input_value: input_value)
    edit_message :text, answer_params
  end

  def origin_callback_query(input_value = nil, *_args)
    answer_params = BotCommands::OriginSearch.call(input_value: input_value)
    edit_message :text, answer_params
  end

  def glossary_callback_query(input_value = nil, *_args)
    answer_params = BotCommands::GlossarySearch.call(input_value: input_value)
    edit_message :text, answer_params
  end

  def tool_callback_query(input_value = nil, *_args)
    answer_params = BotCommands::ToolSearch.call(input_value: input_value)
    edit_message :text, answer_params
  end

  def equipment_callback_query(input_value = nil, *_args)
    answer_params = BotCommands::EquipmentSearch.call(input_value: input_value)
    edit_message :text, answer_params
  end

  def species_callback_query(input_value = nil, *_args)
    answer_params = BotCommands::SpeciesSearch.call(input_value: input_value)
    edit_message :text, answer_params
  end

  def go_back_callback_query(_step = nil, *_args)
    history_item = pop_history_item!
    if history_item.present?
      send(history_item[:action], history_item[:input_value])
    else
      respond_with :message, text: "Не найден последний ответ от сервера", reply_markup: {}
    end
  end

  def pick_mention_callback_query(*args)
    selected_object = Mention.find(args[0].to_i)

    mentionable = selected_object.another_mentionable.decorate
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
end
