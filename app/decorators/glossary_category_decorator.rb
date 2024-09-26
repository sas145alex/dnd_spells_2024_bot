class GlossaryCategoryDecorator < ApplicationDecorator
  delegate_all

  def title
    object.title
  end

  def parse_mode_for_telegram
    "HTML"
  end
end
