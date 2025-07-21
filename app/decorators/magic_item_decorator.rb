class MagicItemDecorator < ApplicationDecorator
  def global_search_title
    "[Артефакт] #{super.capitalize}"
  end

  def description_for_telegram
    @description_for_telegram ||= begin
      str = "<b>#{title}</b>\n\n"
      str.concat("<b>Оригинальное название</b> #{original_title}\n")
      str.concat("<b>Категория</b> #{human_enum_name(:category)}\n")
      str.concat("<b>Редкость</b> #{human_enum_name(:rarity)}\n")
      str.concat("<b>Настройка</b> #{human_enum_name(:attunement)}\n")
      str.concat("<b>Имеет заряды</b> #{I18n.t(charges)}\n")
      str.concat("<b>Проклято</b> #{I18n.t(cursed)}\n")
      str.concat("<b>Цена</b> #{price}\n")
      str.concat("\n")
      str.concat(h.markdown_to_telegram_markdown(object.description))
      str.strip
    end
  end
end
