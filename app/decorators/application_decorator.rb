class ApplicationDecorator < Draper::Decorator
  delegate_all

  def description_for_telegram
    @description_for_telegram ||= h.markdown_to_telegram_markdown(object.description).strip
  end

  def parse_mode_for_telegram
    "HTML"
  end

  def global_search_title
    title
  end
end
