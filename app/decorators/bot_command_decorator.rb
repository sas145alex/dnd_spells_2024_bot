class BotCommandDecorator < ApplicationDecorator
  def title
    if tool?
      "Подробнее о инструментах"
    else
      object.title
    end
  end
end
