module BotCommands
  class SpeciesSearch < BaseCommand
    def call
      if input_value.blank?
        provide_race_variants
      elsif race_selected?
        provide_race_details
      else
        invalid_input
      end
    end

    def initialize(input_value: nil)
      @input_value = input_value
    end

    private

    attr_reader :input_value

    def provide_race_variants
      variants = ::Race.published.ordered
      options = keyboard_options(variants)
      inline_keyboard = options.in_groups_of(3, false)
      inline_keyboard.append([go_back_button])
      reply_markup = {inline_keyboard: inline_keyboard}
      {
        text: "Выберете расу/вид:",
        reply_markup: reply_markup,
        parse_mode: parse_mode
      }
    end

    def provide_race_details
      text = <<~HTML
        <b>#{selected_object.title}</b>

        #{selected_object.description_for_telegram}
      HTML
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

    def race_selected?
      selected_object.is_a?(::Race)
    end

    def callback_prefix
      "species"
    end
  end
end
