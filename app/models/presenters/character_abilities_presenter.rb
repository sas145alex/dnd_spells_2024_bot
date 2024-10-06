module Presenters
  class CharacterAbilitiesPresenter < ApplicationOperation
    class Variant
      extend Dry::Initializer

      option :id
      option :title
      option :level
      option :to_global_id
    end

    EMOJI = "⭐️"

    def initialize(character_klass:)
      @character_klass = character_klass
    end

    def call
      abilities = raw_abilities.reject { |ability| ability.levels.blank? }

      decorated_abilities = abilities.map(&:decorate)
      variants = []
      decorated_abilities.each do |decorated_ability|
        decorated_ability.levels.each do |level|
          variant = Variant.new(
            id: decorated_ability.id,
            title: "[#{level}] #{decorated_ability.title}",
            to_global_id: decorated_ability.to_global_id,
            level: level
          )
          variants << variant
        end
      end

      variants.sort_by(&:level)
    end

    private

    attr_reader :character_klass

    delegate :parent_klass, to: :character_klass

    def raw_abilities
      @raw_abilities ||= begin
        scope = base_scope
        records = scope.where(character_klass: character_klass)
        unless character_klass.base_klass?
          records = records.or(scope.where(character_klass: parent_klass))
        end
        records
      end
    end

    def base_scope
      ::CharacterKlassAbility.published
    end
  end
end
