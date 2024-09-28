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

  def mention_types_for_select
    %w[Creature Spell WildMagic]
  end
end
