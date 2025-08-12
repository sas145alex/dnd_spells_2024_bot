class AddSourceToCreatures < ActiveRecord::Migration[8.0]
  def change
    add_column :creatures, :edition_source, :string, null: false, default: "PHB24"
    change_column_default :creatures, :edition_source, from: "PHB24", to: "MM25"
    add_column :creatures, :import_source, :string, null: false, default: "phb24_manual_transfer"
    add_column :creatures, :creature_type, :string, null: false, default: "unknown"
    add_column :creatures, :creature_subtype, :string, null: true
    add_column :creatures, :challenge_rating, :float, null: false, default: 0.0
    add_column :creatures, :armor_class, :integer, null: false, default: 0
    add_column :creatures, :hit_points, :integer, null: false, default: 0
    add_column :creatures, :hit_points_formula, :string, null: true
    add_column :creatures, :creature_size, :string, null: false, default: "unknown"
    add_column :creatures, :original_description, :string, null: false, default: ""
  end
end
