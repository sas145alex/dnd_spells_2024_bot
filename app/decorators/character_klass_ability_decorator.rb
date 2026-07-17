class CharacterKlassAbilityDecorator < ApplicationDecorator
  # Marks an ability as the subclass's own rather than the base class's. Deliberately not a star —
  # ⭐ means "favorited" everywhere in the bot (Favorites::Marks).
  EMOJI = "🔹"

  def title
    if object.character_klass.base_klass?
      object.title
    else
      "#{EMOJI} #{object.title}"
    end
  end
end
