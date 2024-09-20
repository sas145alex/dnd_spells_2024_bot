class SpellDecorator < ApplicationDecorator
  delegate_all

  def title
    str = ""
    str.concat(object.title) if object.title.present?
    str.concat(" [#{object.original_title}]") if object.original_title.present?
    str
  end

  def parse_mode_for_telegram
    "HTML"
  end

  def description_for_telegram
    @description_for_telegram ||= h.markdown_to_telegram_markdown(object.description)
  end
end
