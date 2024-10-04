module BotCommands
  class OriginSearch < BaseCommand
    def call
      if input_value.blank?
        give_origins
      elsif origin_selected?
        give_detailed_selected_object
      elsif descriptive_subcommand_selected?
        give_general_info_of_section
      elsif ability_selected?
        give_origins_by_ability
      elsif abilities_search_subcommand_selected?
        provide_abilities
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
      inline_keyboard.prepend([search_by_ability_subcommand])
      inline_keyboard.prepend(keyboard_option_section_info)
      reply_markup = {inline_keyboard: inline_keyboard}

      {
        text: "Выберете происхождение",
        reply_markup: reply_markup,
        parse_mode: parse_mode
      }
    end

    def give_origins_by_ability
      ids = Segment.where(attribute_resource: selected_object, resource_type: "Origin").pluck(:resource_id)
      resources = origin_scope.where(id: ids)
      variants = resources.all
      options = keyboard_options(variants)
      inline_keyboard = options.in_groups_of(2, false)
      inline_keyboard.prepend(keyboard_option_section_info)
      reply_markup = {inline_keyboard: inline_keyboard}

      {
        text: "Выберете происхождение",
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
      reply_markup = {inline_keyboard: inline_keyboard}

      {
        text: text,
        reply_markup: reply_markup,
        parse_mode: parse_mode
      }
    end

    def provide_abilities
      text = "Выбере характеристиру, которую хотите улучшить"
      options = CharacterAbility.ordered.map do |item|
        {
          text: item.title,
          callback_data: "#{callback_prefix}:#{item.to_global_id}"
        }
      end
      inline_keyboard = options.in_groups_of(2, false)
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

    def ability_selected?
      selected_object.is_a?(CharacterAbility)
    end

    def origin_scope
      ::Origin.published.ordered
    end

    def callback_prefix
      "origin"
    end
  end
end
