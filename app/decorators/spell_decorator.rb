class SpellDecorator < ApplicationDecorator
  def title
    str = ""
    str.concat("[#{object.level}] ") if object.level.present?
    str.concat(object.title) if object.title.present?
    str.concat(" [#{object.original_title}]") if object.original_title.present?
    str.strip
  end
end
