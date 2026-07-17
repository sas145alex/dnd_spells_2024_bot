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

    def initialize(input_value: nil, subklass_gid: nil, user: nil)
      @input_value = input_value
      @subklass_gid = subklass_gid
      @user = user
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
        text: "Выбери класс",
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
        text: "Выбери подкласс",
        reply_markup: reply_markup,
        parse_mode: parse_mode
      }
    end

    def provide_subklass_description
      klass_record = selected_object.use_parent_description? ? selected_object.parent_klass : selected_object
      klass_record = klass_record.decorate
      text = <<~HTML
        <b>Выбрано:</b> #{selected_object.title}

        #{klass_record.description_for_telegram}
      HTML
      Presenters::LeafCard.call(
        object: selected_object,
        user: user,
        text: text,
        extra_rows: subklass_extra_rows
      )
    end

    def subklass_extra_rows
      rows = []
      rows << [subresource_button] if subresource_button
      if selected_object.has_spells?
        rows << [{text: "Доступные заклинания", callback_data: "prefill_klass_spells:#{selected_object.to_global_id}"}]
      end
      rows << [{text: "Умения", callback_data: "abilities:#{selected_object.to_global_id}"}]
      rows
    end

    def subresource_button
      resource =
        if selected_object.use_invocations? then [Invocation, "invocations"]
        elsif selected_object.use_metamagic? then [Metamagic, "metamagics"]
        elsif selected_object.use_maneuvers? then [Maneuver, "maneuvers"]
        elsif selected_object.use_psionic_powers? then [PsionicPower, "psionic_powers"]
        elsif selected_object.use_plans? then [Plan, "plans"]
        elsif selected_object.use_arcane_shots? then [ArcaneShot, "arcane_shots"]
        end
      return unless resource

      klass, callback = resource
      {text: klass.model_name.human(count: 999), callback_data: "#{callback}:"}
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
      ::CharacterKlass.ordered.published
    end

    def callback_prefix
      "class"
    end
  end
end
