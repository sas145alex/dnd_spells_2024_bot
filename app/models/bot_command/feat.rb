class BotCommand::Feat < ApplicationOperation
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
    if input_value.nil?
      "Выберете категорию"
    elsif category_selected?
      translated_category = Feat.human_enum_names(:category, input_value, locale: locale)
      <<~HTML
        Вы выбрали категорию: <b>#{translated_category}</b>
        Элементов в категории: <b>#{feat_scope.count}</b>
      HTML
    elsif feat_selected? && feat.nil?
      "Не найдено"
    elsif feat_selected?
      <<~HTML
        <b>#{feat.title}</b>
        <i>#{feat.human_enum_name(:category, locale: locale)}</i>

        #{feat.description_for_telegram}
      HTML
    else
      "Невалидное значение"
    end
  end

  def reply_markup
    if input_value.nil?
      enums = Feat.human_enum_names(:category, locale: locale)
      options = enums.map do |enum_raw_value, translation|
        {
          text: translation,
          callback_data: "feat:#{enum_raw_value}"
        }
      end
      inline_keyboard = options.in_groups_of(2, false)
      {inline_keyboard: inline_keyboard}
    elsif category_selected?
      options = feat_scope.all.pluck(:id, :title).to_a.map do |item|
        {
          text: item.last,
          callback_data: "feat:#{item.first}"
        }
      end
      inline_keyboard = options.in_groups_of(2, false)
      {inline_keyboard: inline_keyboard}
    elsif feat_selected? && feat
      mentions = feat.mentions.map do |mention|
        {
          text: mention.another_mentionable.decorate.title,
          callback_data: "pick_mention:#{mention.id}"
        }
      end

      inline_keyboard = mentions.in_groups_of(4, false)
      {inline_keyboard: inline_keyboard}
    else
      {}
    end
  end

  def parse_mode
    "HTML"
  end

  def category_selected?
    input_value.to_s.in?(Feat.categories.keys)
  end

  def feat_selected?
    input_value.to_s.match?(/^\d+$/)
  end

  def feat
    @feat ||= Feat.find_by(id: input_value.to_s.to_i)&.decorate
  end

  def feat_scope
    Feat.published.ordered.where(category: input_value)
  end

  def locale
    "ru"
  end
end
