module BotCommands
  class GlobalSearch
    class Filters < BaseCommand
      SELECTED_SYMBOL = "✅".freeze
      UNSELECTED_SYMBOL = "🚫".freeze

      def self.all_klasses
        @all_klasses ||= Multisearchable.used_klasses
      end

      def self._reset_memoized_commands
        return unless defined?(@all_klasses)
        remove_instance_variable(:@all_klasses)
      end

      def call
        toggle_filter_category! if selected_klass

        [{type: :edit, answer: provide_filters}]
      end

      def initialize(user:, selected_klass:)
        @selected_klass = selected_klass
        @user = user
      end

      private

      attr_reader :selected_klass
      attr_reader :user

      def provide_filters
        text = "Разделы справочника по которым проводится поиск"
        options = options_for_filter

        inline_keyboard = options.in_groups_of(2, false)
        reply_markup = {inline_keyboard: inline_keyboard}

        {
          text: text,
          reply_markup: reply_markup,
          parse_mode: parse_mode
        }
      end

      def options_for_filter
        all_klasses = self.class.all_klasses
        unselected_klasses = current_unselected_klasses
        all_klasses.map do |klass|
          name = klass.model_name.human
          symbol = unselected_klasses.include?(klass.to_s) ? UNSELECTED_SYMBOL : SELECTED_SYMBOL
          text = "#{name} #{symbol}"
          {
            text: text,
            callback_data: "#{callback_prefix}:#{klass}"
          }
        end
      end

      def toggle_filter_category!
        old_value = current_unselected_klasses
        new_value = if old_value.include?(selected_klass)
          old_value - [selected_klass]
        else
          old_value << selected_klass
        end
        user.update(unselected_search_categories: new_value)
      end

      def current_unselected_klasses
        user.unselected_search_categories.uniq || []
      end

      def callback_prefix
        "search_filters"
      end
    end
  end
end
