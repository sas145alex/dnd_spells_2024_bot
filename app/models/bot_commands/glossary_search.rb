module BotCommands
  class GlossarySearch < BaseCommand
    def call
      if input_value.blank?
        provide_top_level_categories
      elsif selected_object.is_a?(GlossaryCategory) && selected_object.with_items?
        provide_glossary_category_items
      elsif selected_object.is_a?(GlossaryCategory)
        provide_detailed_glossary_category
      elsif selected_object.is_a?(GlossaryItem)
        provide_detailed_glossary_item
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
      text = "Выберете категорию:"

      variants = GlossaryCategory.top_level.published.ordered
      options = keyboard_options(variants)
      inline_keyboard = options.in_groups_of(2, false)
      reply_markup = {inline_keyboard: inline_keyboard}

      {
        text: text,
        reply_markup: reply_markup,
        parse_mode: parse_mode
      }
    end

    def provide_glossary_category_items
      parent_category_text = if selected_object.top_level?
        ""
      else
        "<b>Родительская категория:</b> #{selected_object.parent_category.title}"
      end
      text = <<~HTML
        "#{parent_category_text}"
        <b>Категория:</b> #{selected_object.title}
        <b>Всего терминов:</b> #{selected_object.items.count}

        Выберите термин:
      HTML

      variants = selected_object.items.ordered
      options = keyboard_options(variants)
      inline_keyboard = options.in_groups_of(2, false)
      inline_keyboard.append([go_back_button])
      reply_markup = {inline_keyboard: inline_keyboard}

      {
        text: text,
        reply_markup: reply_markup,
        parse_mode: parse_mode
      }
    end

    def provide_detailed_glossary_category
      text = <<~HTML
        <b>Категория:</b> #{selected_object.title}
        <b>Всего подкатегорий:</b> #{selected_object.subcategories.count}

        Выберете категорию:
      HTML
      variants = selected_object.subcategories.published.ordered
      options = keyboard_options(variants)
      inline_keyboard = options.in_groups_of(2, false)
      inline_keyboard.append([go_back_button])
      reply_markup = {inline_keyboard: inline_keyboard}

      {
        text: text,
        reply_markup: reply_markup,
        parse_mode: parse_mode
      }
    end

    def provide_detailed_glossary_item
      text = <<~HTML
        <b>#{selected_object.title}</b>

        #{selected_object.description_for_telegram}
      HTML

      mentions = keyboard_mentions_options(selected_object)
      inline_keyboard = mentions.in_groups_of(2, false)
      inline_keyboard.append([go_back_button])
      reply_markup = {inline_keyboard: inline_keyboard}

      {
        text: text,
        reply_markup: reply_markup,
        parse_mode: parse_mode
      }
    end

    def callback_prefix
      "glossary"
    end
  end
end
