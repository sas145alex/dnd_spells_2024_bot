class ToolDecorator < ApplicationDecorator
  def global_search_title
    "[Инструменты] #{super.capitalize}"
  end
end
