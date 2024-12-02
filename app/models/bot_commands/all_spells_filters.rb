module BotCommands
  class AllSpellsFilters < BaseCommand
    FILTER_VALUE_SEPARATOR = "__"
    SELECTED_SYMBOL = "✅".freeze
    RESET_SYMBOL = "🚫".freeze
    SPELL_SYMBOL = "✨".freeze
    SESSION_KEY = :all_spells_filters
    FILTER_CATEGORIES = {
      "klasses" => "Классы",
      "levels" => "Уровень",
      "ritual" => "Ритуал",
      "schools" => "Школа",
      "concentration" => "Концентрация",
      "casting_times" => "Время накладывания"
    }

    def call
      if invalid_input?
        [{type: :message, answer: invalid_input}]
      elsif step == :set_filter
        update_session_filters
        [{type: :edit, answer: provide_categories}]
      elsif filter_category_selected?
        [{type: :edit, answer: provide_specific_filters}]
      else
        [{type: :edit, answer: provide_categories}]
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

    def update_session_filters
      filter_type, new_value = input_value.split(FILTER_VALUE_SEPARATOR)

      if filter_type == "reset"
        session.delete(SESSION_KEY)
        return
      end

      return unless filter_type.in?(FILTER_CATEGORIES.keys)

      session[SESSION_KEY] ||= {}
      if session[SESSION_KEY][filter_type] == new_value
        session[SESSION_KEY].delete(filter_type)
        session.delete(SESSION_KEY) if session[SESSION_KEY].blank?
      else
        session[SESSION_KEY][filter_type] = new_value
      end
    end

    def provide_specific_filters
      selected_filter_value = current_filters[current_filter_category]
      FetchCategoryFilters.call(current_filter_category, selected_filter_value, separator: FILTER_VALUE_SEPARATOR)
    end

    def provide_categories
      options = FILTER_CATEGORIES.map do |category, title|
        text = current_filters.key?(category) ? "#{title} #{SELECTED_SYMBOL}" : title
        {
          text: text,
          callback_data: "#{callback_prefix}:#{category}"
        }
      end

      text = <<~HTML.chomp
        #{display_current_filters}

        Выбери категорию фильтра:
      HTML

      inline_keyboard = options.in_groups_of(2, false)
      inline_keyboard.append([reset_filters_button]) if session.key?(SESSION_KEY)
      inline_keyboard.append([link_to_all_spells])
      reply_markup = {inline_keyboard: inline_keyboard}

      {
        text: text,
        reply_markup: reply_markup,
        parse_mode: parse_mode
      }
    end

    def display_current_filters
      DisplayFilters.call(current_filters)
    end

    def reset_filters_button
      {
        text: "Сбросить фильтры #{RESET_SYMBOL}",
        callback_data: "all_spells_set_filters:reset"
      }
    end

    def link_to_all_spells
      {
        text: "Поиск заклинаний #{SPELL_SYMBOL}",
        callback_data: "all_spells:"
      }
    end

    def filter_category_selected?
      current_filter_category.present?
    end

    def current_filter_category
      @current_filter_category ||= FILTER_CATEGORIES.keys.find { |category| input_value.to_s.match?(category) }
    end

    def current_filters
      session[SESSION_KEY] || {}
    end

    def invalid_input?
      false
    end

    def callback_prefix
      "all_spells_filters"
    end
  end
end
