class RaceDecorator < ApplicationDecorator
  def global_search_title
    "[Вид] #{super.capitalize}"
  end
end
