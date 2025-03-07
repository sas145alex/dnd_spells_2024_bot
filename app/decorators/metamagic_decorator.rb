class MetamagicDecorator < ApplicationDecorator
  def title
    "[#{object.sorcery_points}] #{object.title}"
  end

  def global_search_title
    "[Метамагия] #{super.capitalize}"
  end
end
