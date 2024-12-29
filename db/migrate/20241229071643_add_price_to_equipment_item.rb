class AddPriceToEquipmentItem < ActiveRecord::Migration[7.2]
  def change
    add_column :equipment_items, :price, :string
    add_column :equipment_items, :weight, :string
  end
end
