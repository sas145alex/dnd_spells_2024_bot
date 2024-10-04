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
      elsif selected_object&.is_a?(::EquipmentItem)
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
          callback_data: "equipment:#{key}"
        }
      end
      inline_keyboard = options.in_groups_of(2, false)
      reply_markup = {inline_keyboard: inline_keyboard}

      {
        text: "Выберете категорию",
        reply_markup: reply_markup,
        parse_mode: parse_mode
      }
    end

    def give_subcategories
      variants = equipment_subcategories
      options = variants.map do |key, translation|
        {
          text: translation,
          callback_data: "equipment:#{key}"
        }
      end
      inline_keyboard = options.in_groups_of(2, false)
      reply_markup = {inline_keyboard: inline_keyboard}

      {
        text: "Выберете подкатегорию",
        reply_markup: reply_markup,
        parse_mode: parse_mode
      }
    end

    def give_equipment_items
      variants = EquipmentItem.published.ordered.where(item_type: input_value)
      options = keyboard_options(variants)
      inline_keyboard = options.in_groups_of(1, false)
      reply_markup = {inline_keyboard: inline_keyboard}

      {
        text: "Выберете предмет",
        reply_markup: reply_markup,
        parse_mode: parse_mode
      }
    end

    def give_detailed_equipment_item
      text = selected_object.description_for_telegram
      mentions = selected_object.mentions.map do |mention|
        {
          text: mention.another_mentionable.decorate.title,
          callback_data: "pick_mention:#{mention.id}"
        }
      end

      inline_keyboard = mentions.in_groups_of(1, false)
      reply_markup = {inline_keyboard: inline_keyboard}

      {
        text: text,
        reply_markup: reply_markup,
        parse_mode: parse_mode
      }
    end

    def invalid_input
      {
        text: "Невалидный ввод",
        reply_markup: {},
        parse_mode: parse_mode
      }
    end

    def top_level_category_selected?
      input_value.to_s.in?(TOP_LEVEL_CATEGORIES.keys)
    end

    def subcategory_selected?
      input_value.to_s.in?(EquipmentItem.item_types.keys)
    end

    def equipment_subcategories
      case input_value
      when "weapon"
        types = EquipmentItem.weapon_item_types
        EquipmentItem.human_enum_names(:item_type).slice(*types)
      when "armor"
        types = EquipmentItem.armor_item_types
        EquipmentItem.human_enum_names(:item_type).slice(*types)
      else
        {}
      end
    end

    def keyboard_options(variants)
      variants.map do |variant|
        {
          text: variant.title,
          callback_data: "equipment:#{variant.to_global_id}"
        }
      end
    end

    def selected_object
      @selected_object ||= GlobalID::Locator.locate(input_value)&.decorate
    end

    def parse_mode
      "HTML"
    end
  end
end
