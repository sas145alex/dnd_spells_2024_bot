module BotCommands
  class AllSpells
    class PrefillKlass < BaseCommand
      def call
        if invalid_input?
          [{type: :message, answer: invalid_input}]
        else
          update_filters
          BotCommands::AllSpells.call(input_value: nil, session: session)
        end
      end

      def initialize(session:, input_value: nil)
        @input_value = input_value || ""
        @session = session
      end

      private

      attr_reader :input_value
      attr_reader :session

      def update_filters
        session.delete(session_key) if session.key?(session_key)
        session[session_key] = {}
        session[session_key]["klasses"] = selected_object.main_character_klass.id
      end

      def invalid_input?
        !selected_object.is_a?(::CharacterKlass)
      end

      def current_filters
        session[session_key] || {}
      end

      def session_key
        BotCommands::AllSpellsFilters::SESSION_KEY
      end
    end
  end
end
