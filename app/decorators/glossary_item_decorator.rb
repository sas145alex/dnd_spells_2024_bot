class GlossaryItemDecorator < ApplicationDecorator
  def title
    "#{object.title} [#{object.category.title}]"
  end

  def global_search_title
    "[Термин] #{super.capitalize}"
  end
end
