module BotCommands
  class CharacterKlassAbilitiesSearch < BaseCommand
    def call
      if character_klass_selected?
        provide_abilities
      elsif ability_selected?
        provide_ability_description
      else
        invalid_input
      end
    end

    def initialize(input_value: nil, user: nil)
      @input_value = input_value
      @user = user
    end

    private

    attr_reader :input_value

    def provide_abilities
      text = <<~HTML
        Выбрано: <b>#{selected_object.title}</b>
        Выбери умение:
      HTML
      variants = abilities_variants
      options = keyboard_options(variants)
      inline_keyboard = options.in_groups_of(1, false)
      inline_keyboard.append([go_back_button])
      reply_markup = {inline_keyboard: inline_keyboard}

      {
        text: text,
        reply_markup: reply_markup,
        parse_mode: parse_mode
      }
    end

    def provide_ability_description
      Presenters::LeafCard.call(object: selected_object, user: user)
    end

    def character_klass_selected?
      selected_object.is_a?(::CharacterKlass)
    end

    def ability_selected?
      selected_object.is_a?(::CharacterKlassAbility)
    end

    def abilities_variants
      Presenters::CharacterAbilitiesPresenter.call(character_klass: selected_object)
    end

    def callback_prefix
      "abilities"
    end
  end
end
