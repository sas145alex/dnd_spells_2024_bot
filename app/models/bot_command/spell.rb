class BotCommand::Spell < ApplicationOperation
  SEARCH_VALUE_MIN_LENGTH = 3
  MAX_SEARCH_RESULT_COUNT = 7

  def call
    if input_value_blank?
      {
        text: "Введите название искомого заклинания (не менее 3х символов)",
        parse_mode: parse_mode
      }
    elsif input_value_invalid?
      {
        text: "Невалидный ввод",
        parse_mode: parse_mode
      }
    elsif selected_spell.present?
      render_spell_info
    else
      render_search_results

      yield(found_spells) if block_given?
    end
  end

  def initialize(payload: {}, last_found_spell_ids: [])
    @payload = payload
    @input_value = payload["text"].to_s.strip
    @last_found_spell_ids = last_found_spell_ids
  end

  private

  attr_reader :payload
  attr_reader :input_value
  attr_reader :last_found_spell_ids

  def input_value_blank?
    input_value.blank? || input_value.starts_with?("/")
  end

  def input_value_invalid?
    input_value.size < SEARCH_VALUE_MIN_LENGTH && last_found_spell_ids.blank?
  end

  def render_spell_info
    text = selected_spell.description_for_telegram
    parse_mode = selected_spell.parse_mode_for_telegram
    mentions = selected_spell.mentions.map do |mention|
      {
        text: mention.another_mentionable.decorate.title,
        callback_data: "pick_mention:#{mention.id}"
      }
    end

    inline_keyboard = mentions.in_groups_of(4, false)
    reply_markup = {inline_keyboard: inline_keyboard}

    Telegram::UserMetricsJob.perform_later(payload)
    Telegram::SpellMetricsJob.perform_later(selected_spell.id)

    {
      text: text,
      reply_markup: reply_markup,
      parse_mode: parse_mode
    }
  end

  def render_search_results
    if found_spells.blank?
      {
        text: "Вариантов не найдено",
        reply_markup: {},
        parse_mode: parse_mode
      }
    else
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
      {
        text: text,
        reply_markup: reply_markup,
        parse_mode: parse_mode
      }
    end
  end

  def selected_spell
    @selected_spell ||= if spell_id_specified?
      Spell.find_by!(id: last_found_spells[payload["text"]]).decorate
    end
  end

  def found_spells
    @found_spells ||= Spell
      .published
      .select(:id, :title, :original_title)
      .search_by_title(payload["text"])
      .limit(MAX_VARIANTS_SIZE)
      .map(&:decorate)
  end

  def spell_id_specified?
    payload["text"].to_i.in?(last_found_spells.pluck(:id))
  end

  def parse_mode
    "HTML"
  end

  def locale
    "ru"
  end
end
