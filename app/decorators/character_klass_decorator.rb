class CharacterKlassDecorator < ApplicationDecorator
  def title
    if object.base_klass?
      object.title
    else
      "#{object.parent_klass.title} - #{object.title}"
    end
  end
end