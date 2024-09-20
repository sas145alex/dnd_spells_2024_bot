class AddRequestedCountToSpells < ActiveRecord::Migration[7.2]
  def change
    add_column :spells,
      :requested_count,
      :integer,
      null: false,
      default: 0
  end
end
