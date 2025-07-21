class AddSearchableTitleToMagicItems < ActiveRecord::Migration[8.0]
  def change
    add_column :magic_items, :searchable_title, :string, null: false, default: ""
  end
end
