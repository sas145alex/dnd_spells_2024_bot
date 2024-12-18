module BotCommands
  class OriginSearch < BaseCommand
    def call
      if input_value.blank?
        give_origins
      elsif origin_selected?
        give_detailed_selected_object
      elsif descriptive_subcommand_selected?
        give_general_info_of_section
      elsif characteristic_selected?
        give_origins_by_characteristic
      elsif characteristic_search_selected?
        provide_characteristics
      else
        invalid_input
      end
    end

    def initialize(input_value: nil)
      @input_value = input_value
    end

    private

    attr_reader :input_value

    def give_origins
      variants = origin_scope.all
      options = keyboard_options(variants)
      inline_keyboard = options.in_groups_of(2, false)
      inline_keyboard.prepend([search_by_characteristic_subcommand])
      inline_keyboard.prepend(keyboard_option_section_info)
      inline_keyboard.append([go_back_button])
      reply_markup = {inline_keyboard: inline_keyboard}

      {
        text: "Выбери происхождение",
        reply_markup: reply_markup,
        parse_mode: parse_mode
      }
    end

    def give_origins_by_characteristic
      ids = Segment.where(attribute_resource: selected_object, resource_type: "Origin").pluck(:resource_id)
      resources = origin_scope.where(id: ids)
      variants = resources.all
      options = keyboard_options(variants)
      inline_keyboard = options.in_groups_of(2, false)
      inline_keyboard.prepend(keyboard_option_section_info)
      inline_keyboard.append([go_back_button])
      reply_markup = {inline_keyboard: inline_keyboard}

      {
        text: "Выбери происхождение",
        reply_markup: reply_markup,
        parse_mode: parse_mode
      }
    end

    def give_detailed_selected_object
      text = <<~HTML
        <b>#{selected_object.title}</b>

        #{selected_object.description_for_telegram}
      HTML
      mentions = keyboard_mentions_options(selected_object)
      inline_keyboard = mentions.in_groups_of(1, false)
      inline_keyboard.append([go_back_button])
      reply_markup = {inline_keyboard: inline_keyboard}

      {
        text: text,
        reply_markup: reply_markup,
        parse_mode: parse_mode
      }
    end

    def give_general_info_of_section
      text = selected_object.description_for_telegram
      mentions = keyboard_mentions_options(selected_object)
      inline_keyboard = mentions.in_groups_of(1, false)
      inline_keyboard.append([go_back_button])
      reply_markup = {inline_keyboard: inline_keyboard}

      {
        text: text,
        reply_markup: reply_markup,
        parse_mode: parse_mode
      }
    end

    def provide_characteristics
      text = "Выбере характеристиру, которую хотите улучшить"
      options = Characteristic.ordered.map do |item|
        {
          text: item.title,
          callback_data: "#{callback_prefix}:#{item.to_global_id}"
        }
      end
      inline_keyboard = options.in_groups_of(2, false)
      inline_keyboard.append([go_back_button])
      reply_markup = {inline_keyboard: inline_keyboard}

      {
        text: text,
        reply_markup: reply_markup,
        parse_mode: parse_mode
      }
    end

    def keyboard_option_section_info
      variants = [::BotCommand.origin.decorate]
      keyboard_options(variants)
    end

    def origin_selected?
      selected_object.is_a?(::Origin)
    end

    def descriptive_subcommand_selected?
      selected_object.is_a?(BotCommand)
    end

    def characteristic_selected?
      selected_object.is_a?(Characteristic)
    end

    def origin_scope
      ::Origin.published.ordered
    end

    def callback_prefix
      "origin"
    end
  end
end
