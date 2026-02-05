module BotCommands
  class FeatSearch < BaseCommand
    def call
      if input_value.blank?
        provide_top_level_categories
      elsif category_selected?
        provide_feats_by_category
      elsif characteristic_selected?
        provide_feats_by_characteristic
      elsif feat_selected?
        provide_detailed_feat_info
      elsif characteristic_search_selected?
        provide_characteristics
      else
        invalid_input
      end
    end

    def initialize(input_value: nil)
      @input_value = input_value
    end

    private

    attr_reader :input_value

    def provide_top_level_categories
      enums = ::Feat.human_enum_names(:category, locale: locale)
      options = enums.map do |translation, enum_raw_value|
        {
          text: translation,
          callback_data: "#{callback_prefix}:#{enum_raw_value}"
        }
      end
      inline_keyboard = options.in_groups_of(2, false)
      inline_keyboard.append([go_back_button])
      reply_markup = {inline_keyboard: inline_keyboard}

      {
        text: "Выбери категорию",
        reply_markup: reply_markup,
        parse_mode: parse_mode
      }
    end

    def provide_feats_by_category
      feats = feat_scope.where(category: input_value)
      options = feats.map do |item|
        {
          text: item.title,
          callback_data: "#{callback_prefix}:#{item.to_global_id}"
        }
      end
      inline_keyboard = options.in_groups_of(2, false)

      if input_value == "general"
        inline_keyboard.prepend([search_by_characteristic_subcommand])
      end
      inline_keyboard.append([go_back_button])

      reply_markup = {inline_keyboard: inline_keyboard}

      {
        text: "Выбери черту",
        reply_markup: reply_markup,
        parse_mode: parse_mode
      }
    end

    def provide_feats_by_characteristic
      ids = Segment.where(attribute_resource: selected_object, resource_type: "Feat").pluck(:resource_id)
      feats = feat_scope.where(id: ids)
      feats = feats.where(category: 'general')
      options = feats.map do |item|
        {
          text: item.title,
          callback_data: "#{callback_prefix}:#{item.to_global_id}"
        }
      end
      inline_keyboard = options.in_groups_of(2, false)
      inline_keyboard.append([go_back_button])
      reply_markup = {inline_keyboard: inline_keyboard}

      {
        text: "Выбери черту",
        reply_markup: reply_markup,
        parse_mode: parse_mode
      }
    end

    def provide_detailed_feat_info
      text = <<~HTML
        <b>#{selected_object.title}</b>
        <i>#{selected_object.human_enum_name(:category, locale: locale)}</i>

        #{selected_object.description_for_telegram}
      HTML
      mentions = keyboard_mentions_options(selected_object)
      inline_keyboard = mentions.in_groups_of(4, false)
      inline_keyboard.append([go_back_button])
      reply_markup = {inline_keyboard: inline_keyboard}

      {
        text: text,
        reply_markup: reply_markup,
        parse_mode: parse_mode
      }
    end

    def provide_characteristics
      text = "Выбере характеристиру, которую хотите улучшить"
      options = Characteristic.ordered.map do |item|
        {
          text: item.title,
          callback_data: "#{callback_prefix}:#{item.to_global_id}"
        }
      end
      inline_keyboard = options.in_groups_of(2, false)
      inline_keyboard.append([go_back_button])
      reply_markup = {inline_keyboard: inline_keyboard}

      {
        text: text,
        reply_markup: reply_markup,
        parse_mode: parse_mode
      }
    end

    def category_selected?
      input_value.to_s.in?(::Feat.categories.keys)
    end

    def feat_selected?
      selected_object.is_a?(::Feat)
    end

    def characteristic_selected?
      selected_object.is_a?(Characteristic)
    end

    def feat_scope
      ::Feat.published.ordered
    end

    def callback_prefix
      "feat"
    end
  end
end
