class AddSearchableTitleToAllModels < ActiveRecord::Migration[7.2]
  def change
    add_column :character_klass_abilities, :searchable_title, :string, null: false, default: ""
    add_column :character_klasses, :searchable_title, :string, null: false, default: ""
    add_column :creatures, :searchable_title, :string, null: false, default: ""
    add_column :equipment_items, :searchable_title, :string, null: false, default: ""
    add_column :feats, :searchable_title, :string, null: false, default: ""
    add_column :glossary_items, :searchable_title, :string, null: false, default: ""
    add_column :invocations, :searchable_title, :string, null: false, default: ""
    add_column :maneuvers, :searchable_title, :string, null: false, default: ""
    add_column :metamagics, :searchable_title, :string, null: false, default: ""
    add_column :origins, :searchable_title, :string, null: false, default: ""
    add_column :races, :searchable_title, :string, null: false, default: ""
    add_column :spells, :searchable_title, :string, null: false, default: ""
    add_column :tools, :searchable_title, :string, null: false, default: ""
  end
end
