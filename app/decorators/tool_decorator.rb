class ToolDecorator < Draper::Decorator
  delegate_all

  def description_for_telegram
    @description_for_telegram ||= h.markdown_to_telegram_markdown(object.description)
  end
end
