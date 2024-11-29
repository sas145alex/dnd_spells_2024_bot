module BotCommands
  class AllSpellsFilters
    class FetchCategoryFilters < ApplicationOperation
      def initialize(category)
        @category = category
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
            text: "Невалидный ввод",
            parse_mode: "HTML"
          }
        end
      end

      private

      attr_reader :category

      def provide_klasses
        options = CharacterKlass.base_klasses.ordered.map do |item|
          klass = item.decorate
          {
            text: klass.title,
            callback_data: "#{callback_prefix}:klass_#{item.id}"
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
          text = level.zero? ? "Заговор" : level.to_s
          {
            text: text,
            callback_data: "#{callback_prefix}:level_#{level}"
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
            callback_data: "#{callback_prefix}:school_#{school}"
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
