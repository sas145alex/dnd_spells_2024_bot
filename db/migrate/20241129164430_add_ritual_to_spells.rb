class AddRitualToSpells < ActiveRecord::Migration[7.2]
  def change
    add_column :spells, :ritual, :boolean, default: false
  end
end
