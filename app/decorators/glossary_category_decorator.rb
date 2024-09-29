class GlossaryCategoryDecorator < ApplicationDecorator
  def title
    object.title
  end
end
