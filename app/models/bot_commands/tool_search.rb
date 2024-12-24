module BotCommands
  class ToolSearch < BaseCommand
    def call
      if input_value.blank?
        provide_top_level_categories
      elsif category_selected?
        give_tools
      elsif selected_object.is_a?(::Tool)
        give_detailed_tool_info
      elsif selected_object.is_a?(::BotCommand)
        give_general_info_of_section
      else
        invalid_input
      end
    end

    def initialize(input_value: nil)
      @input_value = input_value
    end

    private

    attr_reader :input_value

    def provide_top_level_categories
      enums = ::Tool.human_enum_names(:category, locale: locale)
      options = enums.map do |translation, enum_raw_value|
        {
          text: translation,
          callback_data: "#{callback_prefix}:#{enum_raw_value}"
        }
      end
      inline_keyboard = options.in_groups_of(2, false)
      inline_keyboard.append([go_back_button])
      reply_markup = {inline_keyboard: inline_keyboard}

      {
        text: "Выбери категорию",
        reply_markup: reply_markup,
        parse_mode: parse_mode
      }
    end

    def give_tools
      variants = tool_scope.all.where(category: input_value)
      options = keyboard_options(variants)
      inline_keyboard = options.in_groups_of(2, false)
      inline_keyboard.prepend(keyboard_option_tool_info)
      inline_keyboard.prepend(keyboard_option_crafting_info)
      inline_keyboard.append([go_back_button])
      reply_markup = {inline_keyboard: inline_keyboard}

      {
        text: "Выбери набор инстументов",
        reply_markup: reply_markup,
        parse_mode: parse_mode
      }
    end

    def give_detailed_tool_info
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

    def give_general_info_of_section
      give_detailed_tool_info
    end

    def invalid_input
      {
        text: "Невалидный ввод",
        reply_markup: {},
        parse_mode: parse_mode
      }
    end

    def keyboard_option_tool_info
      variants = [::BotCommand.tool.decorate]
      keyboard_options(variants)
    end

    def keyboard_option_crafting_info
      variants = [::BotCommand.crafting.decorate]
      keyboard_options(variants)
    end

    def category_selected?
      input_value.to_s.in?(::Tool.categories.keys)
    end

    def tool_scope
      ::Tool.published.ordered
    end

    def callback_prefix
      "tool"
    end
  end
end
