module BotCommands
  class PsionicPowersSearch < BaseCommand
    def call
      if input_value.blank?
        provide_psionic_powers
      elsif psionic_power_selected?
        provide_psionic_power_description
      else
        invalid_input
      end
    end

    def initialize(input_value: nil)
      @input_value = input_value
    end

    private

    attr_reader :input_value

    def provide_psionic_powers
      text = "Выбери"
      variants = psionic_power_scope
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

    def provide_psionic_power_description
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

    def psionic_power_selected?
      selected_object.is_a?(::PsionicPower)
    end

    def psionic_power_scope
      ::PsionicPower.published.ordered.all.map(&:decorate)
    end

    def callback_prefix
      "psionic_powers"
    end
  end
end
