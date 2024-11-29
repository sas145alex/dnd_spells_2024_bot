module BotCommands
  class AllSpellsFilters
    class ApplyFilters < ApplicationOperation
      def initialize(filters: {}, scope: Spell.all)
        @filters = filters
        @scope = scope
      end

      def call
        modified_scope = scope
        filters.each do |filter_type, value|
          modified_scope = apply_filter(modified_scope, filter_type, value)
        end
        modified_scope
      end

      private

      attr_reader :scope
      attr_reader :filters

      def apply_filter(modified_scope, filter_type, value)
        case filter_type
        when "levels"
          modified_scope.where(level: value.to_i)
        when "schools"
          modified_scope.where(school: value.to_sym)
        when "klasses"
          modified_scope
            .includes(:spells_character_klasses)
            .where(spells_character_klasses: {character_klass_id: value.to_i})
        else
          modified_scope
        end
      end
    end
  end
end
