class WildMagicDecorator < ApplicationDecorator
  delegate_all

  def title
    return "" unless roll
    roll_range = "#{roll.min}..#{roll.max}"
    "Дикая магия (#{roll_range})"
  end

  def parse_mode_for_telegram
    "HTML"
  end

  def description_for_telegram
    @description_for_telegram ||= "<b>#{title}</b>\n\n" +
      h.markdown_to_telegram_markdown(object.description)
  end
end
