module BotCommands
  class CharacterKlassSearch < BaseCommand
    def call
      if input_value.blank? && subklass_gid.nil?
        provide_top_level_klasses
      elsif base_klass_selected?
        provide_subklasses
      elsif subklass_selected?
        provide_subklass_description
      else
        invalid_input
      end
    end

    def initialize(input_value: nil, subklass_gid: nil)
      @input_value = input_value
      @subklass_gid = subklass_gid
    end

    private

    attr_reader :input_value
    attr_reader :subklass_gid

    def provide_top_level_klasses
      variants = character_klass_scope.base_klasses
      options = keyboard_options(variants)
      inline_keyboard = options.in_groups_of(2, false)
      inline_keyboard.append([go_back_button])
      reply_markup = {inline_keyboard: inline_keyboard}

      {
        text: "Выберете класс",
        reply_markup: reply_markup,
        parse_mode: parse_mode
      }
    end

    def provide_subklasses
      variants = character_klass_scope.where(parent_klass: selected_object)
      options = keyboard_options(variants, forced_callback_prefix: "subclass")
      inline_keyboard = options.in_groups_of(2, false)
      base_klass_variant = {text: "Базовый класс", callback_data: "subclass:#{selected_object.to_global_id}"}
      inline_keyboard.prepend([base_klass_variant])
      inline_keyboard.append([go_back_button])
      reply_markup = {inline_keyboard: inline_keyboard}

      {
        text: "Выберете подкласс",
        reply_markup: reply_markup,
        parse_mode: parse_mode
      }
    end

    def provide_subklass_description
      base_klass = selected_object.base_klass? ? selected_object : selected_object.parent_klass.decorate
      text = <<~HTML
        <b>Выбрано:</b> #{selected_object.title}
        
        #{base_klass.description_for_telegram}
      HTML
      mentions = keyboard_mentions_options(selected_object)
      inline_keyboard = mentions.in_groups_of(2, false)
      if selected_object.use_invocations?
        inline_keyboard.append([{text: "Воззвания", callback_data: "invocations:"}])
      end
      inline_keyboard.append([{text: "Умения", callback_data: "abilities:#{selected_object.to_global_id}"}])
      inline_keyboard.append([go_back_button])
      reply_markup = {inline_keyboard: inline_keyboard}

      {
        text: text,
        reply_markup: reply_markup,
        parse_mode: parse_mode
      }
    end

    def base_klass_selected?
      selected_object.is_a?(::CharacterKlass) && subklass_gid.blank?
    end

    def subklass_selected?
      selected_object.is_a?(::CharacterKlass) && subklass_gid.present?
    end

    def gid_value
      subklass_gid || input_value
    end

    def character_klass_scope
      ::CharacterKlass.ordered
    end

    def callback_prefix
      "class"
    end
  end
end
