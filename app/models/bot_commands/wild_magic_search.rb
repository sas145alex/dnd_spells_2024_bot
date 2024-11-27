module BotCommands
  class WildMagicSearch < BaseCommand
    def call
      if wild_magic
        {
          text: text,
          reply_markup: reply_markup,
          parse_mode: parse_mode
        }
      else
        {
          text: "Не найдено",
          reply_markup: {},
          parse_mode: "HTML"
        }
      end
    end

    def initialize(input_value: nil)
      @input_value = input_value
    end

    private

    attr_reader :input_value

    def text
      wild_magic.description_for_telegram
    end

    def reply_markup
      mentions = wild_magic.mentions.map do |mention|
        {
          text: mention.another_mentionable.decorate.title,
          callback_data: "pick_mention:#{mention.id}"
        }
      end

      inline_keyboard = mentions.in_groups_of(4, false)
      {inline_keyboard: inline_keyboard}
    end

    def parse_mode
      wild_magic.parse_mode_for_telegram
    end

    def rand_value
      @rand_value ||= begin
        sanitized_value = input_value.to_s.strip.match?(/^\d+$/) ? input_value.to_i : nil
        sanitized_value || rand(::WildMagic::MIN_ROLL..::WildMagic::MAX_ROLL)
      end
    end

    def wild_magic
      @wild_magic ||= ::WildMagic.find_by_roll(rand_value)&.decorate
    end
  end
end
