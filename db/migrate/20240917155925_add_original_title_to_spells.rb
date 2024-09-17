class AddOriginalTitleToSpells < ActiveRecord::Migration[7.2]
  def change
    add_column :spells, :original_title, :string
  end
end
