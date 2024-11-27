class AddLevelToSpells < ActiveRecord::Migration[7.2]
  def change
    add_column :spells, :level, :integer, null: false, default: 0
    add_column :spells, :school, :string, null: true, comment: "enum"
  end
end
