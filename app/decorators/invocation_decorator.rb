class InvocationDecorator < ApplicationDecorator
  def title
    "[#{object.level}] #{object.title}"
  end

  def global_search_title
    "[Возвврания] #{super.capitalize}"
  end
end
