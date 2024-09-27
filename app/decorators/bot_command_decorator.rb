class BotCommandDecorator < Draper::Decorator
  delegate_all

  def title
    if tool?
      "Подробнее о инструментах"
    else
      object.title
    end
  end

  def description_for_telegram
    @description_for_telegram ||= h.markdown_to_telegram_markdown(object.description)
  end
end
