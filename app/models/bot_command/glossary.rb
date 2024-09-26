class BotCommand::Glossary < ApplicationOperation
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
      "Выберете категорию:"
    elsif selected_object&.is_a?(GlossaryCategory) && selected_object&.top_level?
      <<~HTML
        <b>Категория:</b> #{selected_object.title}
        <b>Всего подкатегорий:</b> #{selected_object.subcategories.count}

        Выберете категорию:
      HTML
    elsif selected_object&.is_a?(GlossaryCategory)
      <<~HTML
        <b>Категория:</b> #{selected_object.parent_category.title}
        <b>Подкатегория:</b> #{selected_object.title}
        <b>Всего терминов:</b> #{selected_object.items.count}

        Выберите термин:
      HTML
    elsif selected_object&.is_a?(GlossaryItem)
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
      variants = GlossaryCategory.top_level.published.ordered
      options = keyboard_options(variants)
      inline_keyboard = options.in_groups_of(2, false)
      {inline_keyboard: inline_keyboard}
    elsif selected_object&.is_a?(GlossaryCategory) && selected_object&.top_level?
      variants = selected_object.subcategories.published.ordered
      options = keyboard_options(variants)
      inline_keyboard = options.in_groups_of(2, false)
      {inline_keyboard: inline_keyboard}
    elsif selected_object&.is_a?(GlossaryCategory)
      variants = selected_object.items.ordered
      options = keyboard_options(variants)
      inline_keyboard = options.in_groups_of(2, false)
      {inline_keyboard: inline_keyboard}
    elsif selected_object&.is_a?(GlossaryItem)
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
        callback_data: "glossary:#{variant.to_global_id}"
      }
    end
  end

  def selected_object
    @selected_object ||= GlobalID::Locator.locate(input_value)&.decorate
  end
end
