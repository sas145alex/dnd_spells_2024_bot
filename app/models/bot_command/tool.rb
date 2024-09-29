class BotCommand::Tool < ApplicationOperation
  def call
    if input_value.blank?
      give_tools
    elsif selected_object&.is_a?(Tool)
      give_detailed_tool_info
    elsif selected_object&.is_a?(::BotCommand)
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

  def give_tools
    variants = tool_scope.all
    options = keyboard_options(variants)
    inline_keyboard = options.in_groups_of(2, false)
    inline_keyboard.prepend(keyboard_option_of_section)
    reply_markup = {inline_keyboard: inline_keyboard}

    {
      text: "Выберете набор инстументов",
      reply_markup: reply_markup,
      parse_mode: parse_mode
    }
  end

  def give_detailed_tool_info
    text = selected_object.description_for_telegram
    {
      text: text,
      reply_markup: {},
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

  def parse_mode
    "HTML"
  end

  def keyboard_option_of_section
    variants = [::BotCommand.tool.decorate]
    keyboard_options(variants)
  end

  def keyboard_options(variants)
    variants.map do |variant|
      {
        text: variant.title,
        callback_data: "tool:#{variant.to_global_id}"
      }
    end
  end

  def tool_scope
    Tool.published.ordered
  end

  def selected_object
    @selected_object ||= GlobalID::Locator.locate(input_value)&.decorate
  end
end