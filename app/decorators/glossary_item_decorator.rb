class GlossaryItemDecorator < ApplicationDecorator
  def title
    "#{object.title} [#{object.category.title}]"
  end
end
