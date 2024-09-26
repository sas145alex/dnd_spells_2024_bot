class BotCommand::Race < ApplicationOperation
  def call
    {
      text: text,
      reply_markup: reply_markup,
      parse_mode: parse_mode
    }
  end

  def initialize(input_value: nil)
    @input_value = input_value
  end

  private

  attr_reader :input_value

  def text
    if input_value.blank?
      "Выберете расу/вид:"
    elsif selected_object&.is_a?(Race)
      <<~HTML
        <b>#{selected_object.title}</b>

        #{selected_object.description_for_telegram}
      HTML
    else
      "Невалидный ввод"
    end
  end

  def reply_markup
    if input_value.blank?
      variants = Race.published.ordered
      options = keyboard_options(variants)
      inline_keyboard = options.in_groups_of(3, false)
      {inline_keyboard: inline_keyboard}
    elsif selected_object&.is_a?(Race)
      {}
    else
      {}
    end
  end

  def parse_mode
    "HTML"
  end

  def keyboard_options(variants)
    variants.map do |variant|
      {
        text: variant.title,
        callback_data: "race:#{variant.to_global_id}"
      }
    end
  end

  def selected_object
    @selected_object ||= GlobalID::Locator.locate(input_value)&.decorate
  end
end
