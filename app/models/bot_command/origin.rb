class BotCommand::Origin < ApplicationOperation
  def call
    if input_value.blank?
      give_origins
    elsif origin_selected?
      give_detailed_origin_info
    else
      {
        text: "Невалидный ввод",
        reply_markup: {},
        parse_mode: parse_mode
      }
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
    reply_markup = {inline_keyboard: inline_keyboard}

    {
      text: "Выберете происхождение",
      reply_markup: reply_markup,
      parse_mode: parse_mode
    }
  end

  def give_detailed_origin_info
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

    inline_keyboard = mentions.in_groups_of(1, false)
    reply_markup = {inline_keyboard: inline_keyboard}

    {
      text: text,
      reply_markup: reply_markup,
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
        callback_data: "origin:#{variant.to_global_id}"
      }
    end
  end

  def origin_selected?
    selected_object.is_a?(Origin)
  end

  def origin_scope
    Origin.published.ordered
  end

  def selected_object
    @selected_object ||= GlobalID::Locator.locate(input_value)&.decorate
  end
end
