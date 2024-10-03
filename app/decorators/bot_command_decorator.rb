class BotCommandDecorator < ApplicationDecorator
  def title
    case object.title
    when object.class::TOOL_ID
      "Подробнее об инструментах"
    when object.class::CRAFTING_ID
      "Подробнее о системе создания предметов"
    when object.class::ORIGIN_ID
      "Подробнее о происхождениях"
    else
      object.title
    end
  end
end
