module BotCommands
  class BastionSearch < BaseCommand
    BASIC_TYPES = %w[construction modification].freeze
    LEVEL_TOKEN = /\Alevel_(\d+)\z/

    def call
      if input_value.blank?
        provide_top_categories
      elsif input_value == "basic"
        provide_basic_group
      elsif input_value == "specialized"
        provide_specialized_group
      elsif input_value == "building"
        provide_text_card(::BotCommand.bastion_building)
      elsif input_value == "obtaining"
        provide_text_card(::BotCommand.bastion_obtaining)
      elsif basic_type_selected?
        provide_basic_bastions
      elsif level_selected?
        provide_leveling_bastions
      elsif bastion_selected?
        provide_detailed_bastion
      else
        invalid_input
      end
    end

    def initialize(input_value: nil)
      @input_value = input_value
    end

    private

    attr_reader :input_value

    def provide_top_categories
      options = [
        {text: BastionDecorator::BASIC_GROUP_TITLE, callback_data: "#{callback_prefix}:basic"},
        {text: BastionDecorator::SPECIALIZED_GROUP_TITLE, callback_data: "#{callback_prefix}:specialized"}
      ]
      screen("Выбери категорию", options.in_groups_of(1, false))
    end

    def provide_basic_group
      inline_keyboard = [[{text: "Строительство", callback_data: "#{callback_prefix}:building"}]]
      type_buttons = BASIC_TYPES.map do |type|
        {
          text: ::Bastion.human_enum_names(:category, type, locale: locale),
          callback_data: "#{callback_prefix}:#{type}"
        }
      end
      inline_keyboard.concat(type_buttons.in_groups_of(2, false))
      screen(BastionDecorator::BASIC_GROUP_TITLE, inline_keyboard)
    end

    def provide_specialized_group
      inline_keyboard = [[{text: "Получение", callback_data: "#{callback_prefix}:obtaining"}]]
      level_buttons = available_levels.map do |level|
        {text: "#{level} уровень", callback_data: "#{callback_prefix}:level_#{level}"}
      end
      inline_keyboard.concat(level_buttons.in_groups_of(2, false))
      screen(BastionDecorator::SPECIALIZED_GROUP_TITLE, inline_keyboard)
    end

    def provide_text_card(command_record)
      decorated = command_record.decorate
      mentions = keyboard_mentions_options(decorated)
      screen(decorated.description_for_telegram, mentions.in_groups_of(2, false))
    end

    def provide_basic_bastions
      variants = bastion_scope.where(category: input_value)
      screen("Выбери сооружение", keyboard_options(variants).in_groups_of(2, false))
    end

    def provide_leveling_bastions
      level = input_value[LEVEL_TOKEN, 1]
      variants = bastion_scope.leveling.where(level: level)
      screen("Выбери сооружение", keyboard_options(variants).in_groups_of(2, false))
    end

    def provide_detailed_bastion
      mentions = keyboard_mentions_options(selected_object)
      screen(selected_object.description_for_telegram, mentions.in_groups_of(2, false))
    end

    def screen(text, inline_keyboard)
      inline_keyboard.append([go_back_button])
      {
        text: text,
        reply_markup: {inline_keyboard: inline_keyboard},
        parse_mode: parse_mode
      }
    end

    def available_levels
      ::Bastion.published.leveling.distinct.pluck(:level).sort
    end

    def basic_type_selected?
      input_value.to_s.in?(BASIC_TYPES)
    end

    def level_selected?
      input_value.to_s.match?(LEVEL_TOKEN)
    end

    def bastion_selected?
      selected_object.is_a?(::Bastion)
    end

    def bastion_scope
      ::Bastion.published.ordered
    end

    def callback_prefix
      "bastion"
    end
  end
end
