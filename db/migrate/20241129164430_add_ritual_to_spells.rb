class AddRitualToSpells < ActiveRecord::Migration[7.2]
  def change
    add_column :spells, :ritual, :boolean, default: false
    add_column :spells, :concentration, :boolean, default: false
    add_column :spells,
      :casting_time,
      :string,
      null: false,
      default: "action"
  end
end
