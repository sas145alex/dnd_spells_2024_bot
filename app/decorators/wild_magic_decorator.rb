class WildMagicDecorator < ApplicationDecorator
  def title
    return "" unless roll
    roll_range = "#{roll.min}..#{roll.max}"
    "Дикая магия (#{roll_range})"
  end

  def description_for_telegram
    @description_for_telegram ||= begin
      str = "<b>#{title}</b>\n\n"
      str.concat(h.markdown_to_telegram_markdown(object.description))
      str.strip
    end
  end
end
