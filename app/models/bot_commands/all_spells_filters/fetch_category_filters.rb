module BotCommands
  class AllSpellsFilters
    class FetchCategoryFilters < ApplicationOperation
      SELECTED_SYMBOL = "✅".freeze

      def initialize(category, current_filters:)
        @category = category
        @current_filters = current_filters
      end

      def call
        case category
        when "klasses"
          provide_klasses
        when "levels"
          provide_levels
        when "schools"
          provide_schools
        else
          {
            text: "Невалидный ввод при выборе фильтра - #{category}",
            parse_mode: "HTML"
          }
        end
      end

      private

      attr_reader :category
      attr_reader :current_filters

      def provide_klasses
        options = CharacterKlass.base_klasses.ordered.map do |item|
          klass = item.decorate
          text = (current_filters["klasses"].to_i == klass.id) ? "#{klass.title} #{SELECTED_SYMBOL}" : klass.title
          {
            text: text,
            callback_data: "#{callback_prefix}:klasses_#{klass.id}"
          }
        end
        inline_keyboard = options.in_groups_of(2, false)
        inline_keyboard.append([return_button])
        reply_markup = {inline_keyboard: inline_keyboard}

        text = <<~HTML
          <b>Фильтрация заклинаний</b>
          
          Выбери класс
        HTML

        {
          text: text,
          reply_markup: reply_markup,
          parse_mode: "HTML"
        }
      end

      def provide_levels
        options = Spell::LEVELS.to_a.map do |level|
          title = level.zero? ? "Заговор" : level.to_s
          text = (current_filters["levels"] == level.to_s) ? "#{title} #{SELECTED_SYMBOL}" : title
          {
            text: text,
            callback_data: "#{callback_prefix}:levels_#{level}"
          }
        end
        inline_keyboard = options.in_groups_of(2, false)
        inline_keyboard.append([return_button])
        reply_markup = {inline_keyboard: inline_keyboard}

        text = <<~HTML
          <b>Фильтрация заклинаний</b>
          
          Выбери уровень заклинаний
        HTML

        {
          text: text,
          reply_markup: reply_markup,
          parse_mode: "HTML"
        }
      end

      def provide_schools
        options = Spell.human_enum_names(:school).map do |school, text|
          {
            text: text,
            callback_data: "#{callback_prefix}:schools_#{school}"
          }
        end
        inline_keyboard = options.in_groups_of(2, false)
        inline_keyboard.append([return_button])
        reply_markup = {inline_keyboard: inline_keyboard}

        text = <<~HTML
          <b>Фильтрация заклинаний</b>
          
          Выбери школу заклинаний
        HTML

        {
          text: text,
          reply_markup: reply_markup,
          parse_mode: "HTML"
        }
      end

      def return_button
        {
          text: "Назад",
          callback_data: "all_spells_filters:"
        }
      end

      def callback_prefix
        "all_spells_set_filters"
      end
    end
  end
end
