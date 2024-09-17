class Telegram::SpellDecorator < ApplicationDecorator
  delegate_all

  def title
    str = ""
    str.concat(object.title) if object.title.present?
    str.concat(" [#{object.original_title}]") if object.original_title.present?
    str
  end
end
