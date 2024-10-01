class BotCommand::Species < ApplicationOperation
  def call
    if input_value.blank?
      provide_race_variants
    elsif selected_object
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
    variants = Race.published.ordered
    options = keyboard_options(variants)
    inline_keyboard = options.in_groups_of(3, false)
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

    mentions = selected_object.mentions.map do |mention|
      {
        text: mention.another_mentionable.decorate.title,
        callback_data: "pick_mention:#{mention.id}"
      }
    end

    inline_keyboard = mentions.in_groups_of(2, false)
    reply_markup = {inline_keyboard: inline_keyboard}

    {
      text: text,
      reply_markup: reply_markup,
      parse_mode: parse_mode
    }
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

  def keyboard_options(variants)
    variants.map do |variant|
      {
        text: variant.title,
        callback_data: "species:#{variant.to_global_id}"
      }
    end
  end

  def selected_object
    @selected_object ||= GlobalID::Locator.locate(input_value, only: Race)&.decorate
  end
end
