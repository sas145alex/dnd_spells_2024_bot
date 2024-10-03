class BotCommand::Origin < ApplicationOperation
  SEARCH_BY_ABILITY_SUBCOMMAND = {text: "Поиск по хар-ке", value: "search_by_ability"}.freeze

  def call
    if input_value.blank?
      give_origins
    elsif origin_selected?
      give_detailed_selected_object
    elsif descriptive_subcommand_selected?
      give_general_info_of_section
    elsif ability_selected?
      give_origins_by_ability
    elsif abilities_search_subcommand_selected?
      provide_abilities
    else
      {
        text: "Невалидный ввод",
        reply_markup: {},
        parse_mode: parse_mode
      }
    end
  end

  def initialize(input_value: nil)
    @input_value = input_value
  end

  private

  attr_reader :input_value

  def give_origins
    variants = origin_scope.all
    options = keyboard_options(variants)
    inline_keyboard = options.in_groups_of(2, false)
    inline_keyboard.prepend([search_by_ability_subcommand])
    inline_keyboard.prepend(keyboard_option_section_info)
    reply_markup = {inline_keyboard: inline_keyboard}

    {
      text: "Выберете происхождение",
      reply_markup: reply_markup,
      parse_mode: parse_mode
    }
  end

  def give_origins_by_ability
    ids = Segment.where(attribute_resource: selected_object, resource_type: "Origin").pluck(:resource_id)
    resources = origin_scope.where(id: ids)
    variants = resources.all
    options = keyboard_options(variants)
    inline_keyboard = options.in_groups_of(2, false)
    inline_keyboard.prepend(keyboard_option_section_info)
    reply_markup = {inline_keyboard: inline_keyboard}

    {
      text: "Выберете происхождение",
      reply_markup: reply_markup,
      parse_mode: parse_mode
    }
  end

  def give_detailed_selected_object
    text = <<~HTML
      <b>#{selected_object.title}</b>

      #{selected_object.description_for_telegram}
    HTML
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

  def give_general_info_of_section
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

  def provide_abilities
    text = "Выбере характеристиру, которую хотите улучшить"
    options = CharacterAbility.ordered.map do |item|
      {
        text: item.title,
        callback_data: "origin:#{item.to_global_id}"
      }
    end
    inline_keyboard = options.in_groups_of(2, false)
    reply_markup = {inline_keyboard: inline_keyboard}

    {
      text: text,
      reply_markup: reply_markup,
      parse_mode: parse_mode
    }
  end

  def parse_mode
    "HTML"
  end

  def search_by_ability_subcommand
    {
      text: SEARCH_BY_ABILITY_SUBCOMMAND[:text],
      callback_data: "origin:#{SEARCH_BY_ABILITY_SUBCOMMAND[:value]}"
    }
  end

  def keyboard_option_section_info
    variants = [::BotCommand.origin.decorate]
    keyboard_options(variants)
  end

  def keyboard_options(variants)
    variants.map do |variant|
      {
        text: variant.title,
        callback_data: "origin:#{variant.to_global_id}"
      }
    end
  end

  def abilities_search_subcommand_selected?
    input_value == SEARCH_BY_ABILITY_SUBCOMMAND[:value]
  end

  def origin_selected?
    selected_object.is_a?(Origin)
  end

  def descriptive_subcommand_selected?
    selected_object.is_a?(BotCommand)
  end

  def ability_selected?
    selected_object.is_a?(CharacterAbility)
  end

  def origin_scope
    Origin.published.ordered
  end

  def selected_object
    @selected_object ||= GlobalID::Locator.locate(input_value)&.decorate
  end
end
