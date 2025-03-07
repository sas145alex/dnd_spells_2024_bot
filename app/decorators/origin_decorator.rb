class OriginDecorator < ApplicationDecorator
  def global_search_title
    "[Происхождение] #{super.capitalize}"
  end
end
