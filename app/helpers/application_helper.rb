module ApplicationHelper
  def markdown_to_html(text)
    FormatChanger.markdown_to_html(text).html_safe
  end

  def markdown_to_telegram_markdown(text)
    FormatChanger.markdown_to_telegram_markdown(text)
  end
end
