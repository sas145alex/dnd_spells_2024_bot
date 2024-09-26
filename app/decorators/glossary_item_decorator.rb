class GlossaryItemDecorator < ApplicationDecorator
  delegate_all

  def title
    "#{object.title} [#{object.category.title}]"
  end

  def parse_mode_for_telegram
    "HTML"
  end

  def description_for_telegram
    @description_for_telegram ||= h.markdown_to_telegram_markdown(object.description)
  end
end
