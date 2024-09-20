class TelegramController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::MessageContext
  include Telegram::Bot::UpdatesController::CallbackQueryContext
  include Telegram::Bot::UpdatesController::Session

  MAX_VARIANTS_SIZE = 7
  SEARCH_VALUE_MIN_LENGTH = 3

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

  def stop_search!(*args)
    set_last_found_spells([])

    reply_markup = {
      remove_keyboard: true
    }

    respond_with :message,
      text: "Поиск окончен",
      reply_markup: reply_markup
  end

  def start_search_spell!(*args)
    save_context("provide_search_variants_for")

    respond_with :message, text: "Введите название искомого заклинания (не менее 3х символов)"
  end

  def provide_search_variants_for(*args)
    save_context("provide_search_variants_for")

    return if search_value_invalid?

    if selected_spell.present?
      text = selected_spell.description_for_telegram
      parse_mode = selected_spell.parse_mode_for_telegram
      mentions = selected_spell.mentions.map do |mention|
        {
          text: mention.another_mentionable.title,
          callback_data: "pick_mention:#{mention.id}"
        }
      end

      inline_keyboard = mentions.in_groups_of(4, false)
      reply_markup = {inline_keyboard: inline_keyboard}
      respond_with :message,
        text: text,
        reply_markup: reply_markup,
        parse_mode: parse_mode

      Telegram::UserMetricsJob.perform_later(payload)
      Telegram::SpellMetricsJob.perform_later(selected_spell.id)

      return
    else
      fetch_new_variants!

      if found_spells.present?
        text = "Найдено несколько вариантов. Выбери:\n\n"
        found_spells.each.with_index(1) do |spell, index|
          text << "#{index}. #{spell.title}\n"
        end
        variants = last_found_spells.keys
        reply_markup = {
          keyboard: [variants, %w[/stop_search]],
          resize_keyboard: true,
          one_time_keyboard: false,
          selective: true
        }
      else
        text = "Не найдено никаких вариантов"
        reply_markup = {}
      end
    end

    respond_with :message, text: text, reply_markup: reply_markup
  end

  def callback_query(*args)
    respond_with :message, text: "default callback answer", reply_markup: {}
  end

  def pick_mention_callback_query(*args)
    mention = Mention.find(args[0].to_i)
    mentionable = mention.another_mentionable.decorate
    text = mentionable.description_for_telegram
    parse_mode = mentionable.parse_mode_for_telegram

    respond_with :message,
      text: text,
      reply_markup: {},
      parse_mode: parse_mode
  end

  private

  def search_value_invalid?
    search_value.size < SEARCH_VALUE_MIN_LENGTH && last_found_spells.empty?
  end

  def search_value
    @search_value ||= payload["text"].chomp
  end

  def last_found_spells
    session[:last_found_spells]
  end

  def set_last_found_spells(spells)
    session[:last_found_spells] = spells.map.with_index(1) { |spell, index| [index.to_s, spell.id] }.to_h
  end

  def selected_spell
    @selected_spell ||= if last_found_spells.present? && payload["text"].in?(last_found_spells.keys)
      spell = Spell.find_by(id: last_found_spells[payload["text"]])
      spell.decorate
    end
  end

  def fetch_new_variants!
    set_last_found_spells(found_spells)
    found_spells
  end

  def found_spells
    @found_spells = Spell
      .published
      .select(:id, :title, :original_title)
      .search_by_title(payload["text"])
      .limit(MAX_VARIANTS_SIZE)
      .map(&:decorate)
  end
end
