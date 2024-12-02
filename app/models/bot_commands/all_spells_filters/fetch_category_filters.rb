module BotCommands
  class AllSpellsFilters
    class FetchCategoryFilters < ApplicationOperation
      SELECTED_SYMBOL = "✅".freeze

      def initialize(filter_type, selected_value = nil, separator: "__")
        @filter_type = filter_type
        @selected_value = selected_value
        @separator = separator
      end

      def call
        case filter_type
        when "klasses"
          provide_klasses
        when "levels"
          provide_levels
        when "schools"
          provide_schools
        when "ritual"
          provide_ritual
        when "concentration"
          provide_concentration
        when "casting_times"
          provide_casting_times
        else
          {
            text: "Невалидный ввод при выборе фильтра - #{filter_type}",
            parse_mode: "HTML"
          }
        end
      end

      private

      attr_reader :filter_type
      attr_reader :selected_value
      attr_reader :separator

      def provide_klasses
        options = CharacterKlass.base_klasses.ordered.map do |item|
          klass = item.decorate
          text = selected?(klass.id) ? "#{klass.title} #{SELECTED_SYMBOL}" : klass.title
          {
            text: text,
            callback_data: "#{callback_prefix}:#{filter_type}__#{klass.id}"
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
          text = selected?(level) ? "#{title} #{SELECTED_SYMBOL}" : title
          {
            text: text,
            callback_data: "#{callback_prefix}:#{filter_type}__#{level}"
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
        options = Spell.human_enum_names(:school).map do |translation, school|
          text = selected?(school) ? "#{translation} #{SELECTED_SYMBOL}" : translation
          {
            text: text,
            callback_data: "#{callback_prefix}:#{filter_type}__#{school}"
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

      def provide_casting_times
        options = Spell.human_enum_names(:casting_time).map do |translation, casting_time|
          text = selected?(casting_time) ? "#{translation} #{SELECTED_SYMBOL}" : translation
          {
            text: text,
            callback_data: "#{callback_prefix}:#{filter_type}__#{casting_time}"
          }
        end
        inline_keyboard = options.in_groups_of(2, false)
        inline_keyboard.append([return_button])
        reply_markup = {inline_keyboard: inline_keyboard}

        text = <<~HTML
          <b>Фильтрация заклинаний</b>
          
          Выбери время накладывания
        HTML

        {
          text: text,
          reply_markup: reply_markup,
          parse_mode: "HTML"
        }
      end

      def provide_ritual
        options = i18n_booleans.map do |value, translation|
          text = selected?(value) ? "#{translation} #{SELECTED_SYMBOL}" : translation
          {
            text: text,
            callback_data: "#{callback_prefix}:#{filter_type}__#{value}"
          }
        end
        inline_keyboard = options.in_groups_of(2, false)
        inline_keyboard.append([return_button])
        reply_markup = {inline_keyboard: inline_keyboard}

        text = <<~HTML
          <b>Фильтрация заклинаний</b>
          
          Можно ли применять заклинание как ритуал
        HTML

        {
          text: text,
          reply_markup: reply_markup,
          parse_mode: "HTML"
        }
      end

      def provide_concentration
        options = i18n_booleans.map do |value, translation|
          text = selected?(value) ? "#{translation} #{SELECTED_SYMBOL}" : translation
          {
            text: text,
            callback_data: "#{callback_prefix}:#{filter_type}__#{value}"
          }
        end
        inline_keyboard = options.in_groups_of(2, false)
        inline_keyboard.append([return_button])
        reply_markup = {inline_keyboard: inline_keyboard}

        text = <<~HTML
          <b>Фильтрация заклинаний</b>
          
          Нужно ли поддерживать концентрацию
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

      def selected?(value)
        value.to_s == selected_value.to_s
      end

      def i18n_booleans(value = nil)
        if value
          I18n.t("types.boolean.#{value}")
        else
          I18n.t("types.boolean")
        end
      end
    end
  end
end
