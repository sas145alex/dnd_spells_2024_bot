class EquipmentItemDecorator < ApplicationDecorator
  def global_search_title
    "[Предмет] #{super.capitalize}"
  end
end
