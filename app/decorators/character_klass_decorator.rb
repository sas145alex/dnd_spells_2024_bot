class CharacterKlassDecorator < ApplicationDecorator
  def title
    if object.base_klass?
      object.title
    else
      "#{object.parent_klass.title} - #{object.title}"
    end
  end

  # Subklasses without their own description inherit the parent klass's, by design. This keeps
  # every render path (global /search, /sections) consistent and avoids sending empty text.
  def description_for_telegram
    return super unless object.use_parent_description?

    object.parent_klass.decorate.description_for_telegram
  end
end
