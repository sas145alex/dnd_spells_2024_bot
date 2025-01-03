module BotCommands
  class AllSpellsFilters
    class DisplayFilters < ApplicationOperation
      def initialize(store)
        @store = store
      end

      def call
        <<~HTML.chomp
          <b>Фильтров выбрано: #{store.keys.size}</b>
          #{filter_info}
        HTML
      end

      private

      attr_reader :store

      def filter_info
        return "" if store.blank?

        index = 0
        store.map do |filter_type, value|
          index += 1
          "#{index}. <b>#{print_filter_type(filter_type)}</b>: <i>#{print_value(filter_type, value)}</i>"
        end.join("\n")
      end

      def print_filter_type(filter_type)
        i18n_store = BotCommands::AllSpellsFilters::FILTER_CATEGORIES
        i18n_store.fetch(filter_type.to_s)
      end

      def print_value(filter_type, value)
        case filter_type
        when "klasses"
          CharacterKlass.find(value.to_i).decorate.title
        when "schools", "casting_times"
          Spell.human_enum_names(filter_type.to_sym, value.to_sym)
        when "levels"
          value.to_i.zero? ? "Заговор" : value
        when "ritual", "concentration"
          boolean = ActiveRecord::Type::Boolean.new.serialize(value)
          boolean ? "Да" : "Нет"
        else
          value
        end
      end
    end
  end
end
