module BotCommands
  class AllSpellsFilters < BaseCommand
    FILTER_CATEGORIES = {
      "klasses" => "Классы",
      "levels" => "Уровень",
      "schools" => "Школа"
    }

    def call
      if invalid_input?
        [{type: :message, answer: invalid_input}]
      elsif step == :set_filters
        raise NotImplementedError
      elsif filter_category_selected?
        [{type: :edit, answer: provide_category_filters}]
      else
        [{type: :edit, answer: provide_filter_categories}]
      end
    end

    def initialize(session:, input_value: nil, step: nil)
      @input_value = input_value || ""
      @session = session
      @step = step
    end

    private

    attr_reader :input_value
    attr_reader :session
    attr_reader :step

    def provide_category_filters
      FetchCategoryFilters.call(current_filter_category)
    end

    def provide_filter_categories
      options = FILTER_CATEGORIES.map do |category, text|
        {
          text: text,
          callback_data: "#{callback_prefix}:#{category}"
        }
      end

      text = <<~HTML
        <b>Текущие фильтры:</b>

        Выбери фильтр:
      HTML

      inline_keyboard = options.in_groups_of(2, false)
      inline_keyboard.append([link_to_all_spells])
      reply_markup = {inline_keyboard: inline_keyboard}

      {
        text: text,
        reply_markup: reply_markup,
        parse_mode: parse_mode
      }
    end

    def link_to_all_spells
      {
        text: "К заклинаниям",
        callback_data: "all_spells:"
      }
    end

    def filter_category_selected?
      current_filter_category.present?
    end

    def current_filter_category
      @current_filter_category ||= FILTER_CATEGORIES.keys.find { |category| category == input_value.to_s }
    end

    def invalid_input?
      false
    end

    def callback_prefix
      "all_spells_filters"
    end
  end
end
