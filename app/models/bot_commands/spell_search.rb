module BotCommands
  class SpellSearch < BaseCommand
    SEARCH_VALUE_MIN_LENGTH = 3
    MAX_SEARCH_RESULT_COUNT = 7

    def call
      if spell_gid.present? && selected_spell.present?
        render_spell_info
      elsif spell_gid.present?
        {
          text: "Указанное заклиннание не найдено",
          parse_mode: parse_mode
        }
      elsif input_value.starts_with?("/") || input_value.size < SEARCH_VALUE_MIN_LENGTH
        text = <<~HTML
          <b>Ты перешел в режим поиска заклинаний.</b>

          Введи название искомого заклинания (не менее 3х символов).
          
          После получения заклинания ты останешься в этом режиме и можешь сразу же ввести название следующего заклинания.
        HTML
        {
          text: text,
          parse_mode: parse_mode
        }
      elsif found_spells.blank?
        {
          text: "Вариантов не найдено",
          reply_markup: {},
          parse_mode: parse_mode
        }
      else
        render_search_results
      end
    end

    def initialize(payload: {}, spell_gid: nil)
      @payload = payload
      @input_value = payload["text"].to_s.strip
      @spell_gid = spell_gid
    end

    private

    attr_reader :payload
    attr_reader :input_value
    attr_reader :spell_gid

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

      {
        text: text,
        reply_markup: reply_markup,
        parse_mode: parse_mode
      }
    end

    def render_search_results
      text = "Найдено несколько вариантов. Выбери:\n\n"
      options = found_spells.map do |item|
        {
          text: item.title,
          callback_data: "spell:#{item.to_global_id}"
        }
      end
      inline_keyboard = options.in_groups_of(1, false)
      {inline_keyboard: inline_keyboard}
      reply_markup = {inline_keyboard: inline_keyboard}

      {
        text: text,
        reply_markup: reply_markup,
        parse_mode: parse_mode
      }
    end

    def selected_spell
      @selected_spell ||= GlobalID::Locator.locate(spell_gid, only: ::Spell)&.decorate
    end

    def found_spells
      @found_spells ||= ::Spell
        .telegram_bot_search(payload["text"], limit: MAX_SEARCH_RESULT_COUNT)
        .select(:id, :title, :original_title)
        .map(&:decorate)
    end

    def parse_mode
      "HTML"
    end

    def locale
      "ru"
    end
  end
end
