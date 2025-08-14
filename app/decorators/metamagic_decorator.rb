class MetamagicDecorator < ApplicationDecorator
  def title
    "[#{object.sorcery_points}] #{object.title}"
  end
end
