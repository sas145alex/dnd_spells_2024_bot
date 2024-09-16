class AddSearchIndexToSpells < ActiveRecord::Migration[7.2]
  def up
    enable_extension("pg_trgm")
    add_index(:spells, :title, name: "index_spells_on_title_gin", using: "gin", opclass: :gin_trgm_ops)
    add_index(:spells, :title, name: "index_spells_on_title")
  end

  def down
    remove_index(:spells, :title, name: "index_spells_on_title")
    remove_index(:spells, :title, name: "index_spells_on_title_gin")
  end
end
