module ApplicationHelper
  def markdown_to_html(text)
    FormatChanger.markdown_to_html(text).html_safe
  end

  def markdown_to_telegram_markdown(text)
    FormatChanger.markdown_to_telegram_markdown(text)
  end

  def mention_types_for_select
    %w[Creature Spell WildMagic]
  end
end
