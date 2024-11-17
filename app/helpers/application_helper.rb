module ApplicationHelper
  def markdown_to_html(text, limit: nil)
    formatted_text = FormatChanger.markdown_to_html(text).html_safe
    if limit
      formatted_text.first(limit) + "..."
    else
      formatted_text
    end
  end

  def markdown_to_telegram_markdown(text)
    FormatChanger.markdown_to_telegram_markdown(text)
  end

  def grouped_categories_for_select(scope: nil, selected: nil)
    categories = scope || GlossaryCategory.ordered
    optgroups = categories
      .group_by { _1.top_level? ? "Top level" : _1.parent_category&.title }
      .transform_values { _1.pluck(:title, :id) }
    grouped_options_for_select(optgroups, selected)
  end

  def grouped_klasses_for_select(scope: nil, selected: nil)
    character_klasses = scope || CharacterKlass.all
    character_klasses = character_klasses
      .left_joins(:parent_klass)
      .select(
        :id,
        :parent_klass_id,
        "character_klasses.title as title",
        "coalesce(parent_klasses_character_klasses.title, 'Base Class') as parent_title"
      )
    optgroups = character_klasses
      .group_by { _1["parent_title"] }
      .transform_values { _1.pluck(:title, :id) }
    base_klasses = optgroups.delete("Base Class")
    optgroups = optgroups.sort_by { |key, _value| key }.to_h
    optgroups = {"Base Class" => base_klasses}.merge(optgroups) # put base classes first
    grouped_options_for_select(optgroups, selected)
  end

  def admins_for_select
    @admin_for_select ||= AdminUser.all.pluck(:email, :id)
  end

  def levels_for_select
    (1..20).to_a
  end

  def mention_types_for_select
    %w[Creature Spell GlossaryItem Feat Tool Origin WildMagic BotCommand]
  end

  def segment_types_for_select
    %w[Characteristic]
  end

  def telegram_users_for_select
    label_expr = Arel.sql("coalesce(username, external_id::text)")
    value_expr = Arel.sql("coalesce(external_id)")
    TelegramUser.pluck(label_expr, value_expr)
  end
end
