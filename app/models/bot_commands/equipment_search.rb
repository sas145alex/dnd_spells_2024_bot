module BotCommands
  class EquipmentSearch < BaseCommand
    TOP_LEVEL_CATEGORIES = {
      "weapon" => "Оружие",
      "armor" => "Доспехи"
    }

    def call
      if input_value.blank?
        give_top_level_categories
      elsif top_level_category_selected?
        give_subcategories
      elsif subcategory_selected?
        give_equipment_items
      elsif equipment_item_selected?
        give_detailed_equipment_item
      else
        invalid_input
      end
    end

    def initialize(input_value: nil)
      @input_value = input_value
    end

    private

    attr_reader :input_value

    def give_top_level_categories
      variants = TOP_LEVEL_CATEGORIES
      options = variants.map do |key, translation|
        {
          text: translation,
          callback_data: "#{callback_prefix}:#{key}"
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

    def give_subcategories
      variants = equipment_subcategories
      options = variants.map do |translation, key|
        {
          text: translation,
          callback_data: "#{callback_prefix}:#{key}"
        }
      end
      inline_keyboard = options.in_groups_of(2, false)
      inline_keyboard.append([go_back_button])
      reply_markup = {inline_keyboard: inline_keyboard}

      {
        text: "Выбери подкатегорию",
        reply_markup: reply_markup,
        parse_mode: parse_mode
      }
    end

    def give_equipment_items
      variants = EquipmentItem.published.ordered.where(item_type: input_value)
      options = keyboard_options(variants)
      group_size = (options.size > 6) ? 2 : 1
      inline_keyboard = options.in_groups_of(group_size, false)
      inline_keyboard.append([go_back_button])
      reply_markup = {inline_keyboard: inline_keyboard}
      text = subcategory_items_screen_text

      {
        text: text,
        reply_markup: reply_markup,
        parse_mode: parse_mode
      }
    end

    def subcategory_items_screen_text
      cmd = if input_value.to_sym.in?(EquipmentItem.armor_item_types)
        BotCommand.memoized_search(title: "#{input_value}_section_description")&.decorate
      end
      cmd ? cmd.description_for_telegram : "Выбери предмет"
    end

    def give_detailed_equipment_item
      text = selected_object.description_for_telegram
      mentions = keyboard_mentions_options(selected_object)
      inline_keyboard = mentions.in_groups_of(1, false)
      inline_keyboard.append([go_back_button])
      reply_markup = {inline_keyboard: inline_keyboard}

      {
        text: text,
        reply_markup: reply_markup,
        parse_mode: parse_mode
      }
    end

    def top_level_category_selected?
      input_value.to_s.in?(TOP_LEVEL_CATEGORIES.keys)
    end

    def subcategory_selected?
      input_value.to_s.in?(EquipmentItem.item_types.keys)
    end

    def equipment_item_selected?
      selected_object.is_a?(EquipmentItem)
    end

    def equipment_subcategories
      case input_value
      when "weapon"
        types = EquipmentItem.weapon_item_types
        EquipmentItem.human_enum_names(:item_type, only: types)
      when "armor"
        types = EquipmentItem.armor_item_types
        EquipmentItem.human_enum_names(:item_type, only: types)
      else
        {}
      end
    end

    def callback_prefix
      "equipment"
    end
  end
end
