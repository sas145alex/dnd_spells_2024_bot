class ManeuverDecorator < ApplicationDecorator
  def global_search_title
    "[Маневры] #{super.capitalize}"
  end
end
