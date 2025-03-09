class InvocationDecorator < ApplicationDecorator
  def title
    "[#{object.level}] #{object.title}"
  end

  def global_search_title
    "[Воззвания] #{super.capitalize}"
  end
end
