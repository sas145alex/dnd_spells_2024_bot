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

  def mention_types_for_select
    %w[Creature Spell WildMagic]
  end
end
