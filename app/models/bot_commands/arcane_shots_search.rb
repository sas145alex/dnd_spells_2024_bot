module BotCommands
  class ArcaneShotsSearch < BaseCommand
    def call
      if input_value.blank?
        provide_arcane_shots
      elsif arcane_shot_selected?
        provide_arcane_shot_description
      else
        invalid_input
      end
    end

    def initialize(input_value: nil)
      @input_value = input_value
    end

    private

    attr_reader :input_value

    def provide_arcane_shots
      text = "Выбери"
      variants = arcane_shot_scope
      options = keyboard_options(variants)
      inline_keyboard = options.in_groups_of(2, false)
      inline_keyboard.append([go_back_button])
      reply_markup = {inline_keyboard: inline_keyboard}

      {
        text: text,
        reply_markup: reply_markup,
        parse_mode: parse_mode
      }
    end

    def provide_arcane_shot_description
      text = selected_object.description_for_telegram
      mentions = keyboard_mentions_options(selected_object)
      inline_keyboard = mentions.in_groups_of(2, false)
      inline_keyboard.append([go_back_button])
      reply_markup = {inline_keyboard: inline_keyboard}

      {
        text: text,
        reply_markup: reply_markup,
        parse_mode: parse_mode
      }
    end

    def arcane_shot_selected?
      selected_object.is_a?(::ArcaneShot)
    end

    def arcane_shot_scope
      ::ArcaneShot.published.ordered.all.map(&:decorate)
    end

    def callback_prefix
      "arcane_shots"
    end
  end
end
