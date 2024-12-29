class AddCategoryToTools < ActiveRecord::Migration[7.2]
  def change
    add_column :tools, :category, :string, null: false, default: "other"
  end
end
