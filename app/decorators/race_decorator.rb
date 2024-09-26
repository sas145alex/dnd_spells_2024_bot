class RaceDecorator < Draper::Decorator
  delegate_all

  def title
    object.title
  end

  def description_for_telegram
    @description_for_telegram ||= h.markdown_to_telegram_markdown(object.description)
  end
end
