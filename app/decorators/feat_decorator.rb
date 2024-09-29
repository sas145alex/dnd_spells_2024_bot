class FeatDecorator < ApplicationDecorator
  def title
    str = ""
    str.concat(object.title) if object.title.present?
    str.concat(" [#{object.original_title}]") if object.original_title.present?
    str
  end
end
