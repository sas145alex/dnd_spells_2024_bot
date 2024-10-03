class BotCommand::Feat < ApplicationOperation
  SEARCH_BY_ABILITY_SUBCOMMAND = {text: "Поиск по хар-ке", value: "search_by_ability"}.freeze

  def call
    if input_value.nil?
      provide_top_level_categories
    elsif category_selected?
      provide_feats_by_category
    elsif ability_selected?
      provide_feats_by_ability
    elsif feat_selected?
      provide_detailed_feat_info
    elsif abilities_search_subcommand_selected?
      provide_abilities
    else
      {
        text: "Невалидное значение",
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

  def provide_top_level_categories
    enums = Feat.human_enum_names(:category, locale: locale)
    options = enums.map do |enum_raw_value, translation|
      {
        text: translation,
        callback_data: "feat:#{enum_raw_value}"
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

  def provide_feats_by_category
    feats = feat_scope.where(category: input_value)
    options = feats.map do |item|
      {
        text: item.title,
        callback_data: "feat:#{item.to_global_id}"
      }
    end
    inline_keyboard = options.in_groups_of(2, false)

    if input_value == "general"
      search_subcommand = {
        text: SEARCH_BY_ABILITY_SUBCOMMAND[:text],
        callback_data: "feat:#{SEARCH_BY_ABILITY_SUBCOMMAND[:value]}"
      }
      inline_keyboard.prepend([search_subcommand])
    end
    inline_keyboard.append([go_back_button])

    reply_markup = {inline_keyboard: inline_keyboard}

    {
      text: "Выберете черту",
      reply_markup: reply_markup,
      parse_mode: parse_mode
    }
  end

  def provide_feats_by_ability
    ids = Segment.where(attribute_resource: selected_object, resource_type: "Feat").pluck(:resource_id)
    feats = feat_scope.where(id: ids)
    options = feats.map do |item|
      {
        text: item.title,
        callback_data: "feat:#{item.to_global_id}"
      }
    end
    inline_keyboard = options.in_groups_of(2, false)
    inline_keyboard.append([go_back_button])
    reply_markup = {inline_keyboard: inline_keyboard}

    {
      text: "Выберете черту",
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
    mentions = selected_object.mentions.map do |mention|
      {
        text: mention.another_mentionable.decorate.title,
        callback_data: "pick_mention:#{mention.id}"
      }
    end

    inline_keyboard = mentions.in_groups_of(4, false)
    inline_keyboard.append([go_back_button])
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
        callback_data: "feat:#{item.to_global_id}"
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

  def go_back_button
    {
      text: "Назад",
      callback_data: "go_back:go_back"
    }
  end

  def parse_mode
    "HTML"
  end

  def abilities_search_subcommand_selected?
    input_value == SEARCH_BY_ABILITY_SUBCOMMAND[:value]
  end

  def category_selected?
    input_value.to_s.in?(Feat.categories.keys)
  end

  def feat_selected?
    selected_object.is_a?(Feat)
  end

  def ability_selected?
    selected_object.is_a?(CharacterAbility)
  end

  def selected_object
    @selected_object ||= GlobalID::Locator.locate(input_value)&.decorate
  end

  def feat_scope
    Feat.published.ordered
  end

  def locale
    "ru"
  end
end
