class BotCommand::Feat < ApplicationOperation
  def call
    if input_value.nil?
      provide_top_level_categories
    elsif category_selected?
      provide_category_items
    elsif feat_selected?
      provide_detailed_feat_info
    else
      {
        text: "Невалидное значение",
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

  def provide_top_level_categories
    enums = Feat.human_enum_names(:category, locale: locale)
    options = enums.map do |enum_raw_value, translation|
      {
        text: translation,
        callback_data: "feat:#{enum_raw_value}"
      }
    end
    inline_keyboard = options.in_groups_of(2, false)
    reply_markup = {inline_keyboard: inline_keyboard}

    {
      text: "Выберете категорию",
      reply_markup: reply_markup,
      parse_mode: parse_mode
    }
  end

  def provide_category_items
    options = feat_scope.map do |item|
      {
        text: item.title,
        callback_data: "feat:#{item.to_global_id}"
      }
    end
    inline_keyboard = options.in_groups_of(2, false)
    reply_markup = {inline_keyboard: inline_keyboard}

    {
      text: "Выберете категорию",
      reply_markup: reply_markup,
      parse_mode: parse_mode
    }
  end

  def provide_detailed_feat_info
    text = <<~HTML
      <b>#{selected_object.title}</b>
      <i>#{selected_object.human_enum_name(:category, locale: locale)}</i>

      #{selected_object.description_for_telegram}
    HTML
    mentions = selected_object.mentions.map do |mention|
      {
        text: mention.another_mentionable.decorate.title,
        callback_data: "pick_mention:#{mention.id}"
      }
    end

    inline_keyboard = mentions.in_groups_of(4, false)
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

  def category_selected?
    input_value.to_s.in?(Feat.categories.keys)
  end

  def feat_selected?
    selected_object.is_a?(Feat)
  end

  def selected_object
    @selected_object ||= GlobalID::Locator.locate(input_value)&.decorate
  end

  def feat_scope
    Feat.published.ordered.where(category: input_value)
  end

  def locale
    "ru"
  end
end
