class CharacterKlassAbilityDecorator < ApplicationDecorator
  EMOJI = "⭐️"

  def title
    if object.character_klass.base_klass?
      object.title
    else
      "#{EMOJI} #{object.title}"
    end
  end

  def global_search_title
    "[Умение] #{super.capitalize}"
  end
end
