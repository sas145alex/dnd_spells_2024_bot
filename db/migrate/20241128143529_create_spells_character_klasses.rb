class CreateSpellsCharacterKlasses < ActiveRecord::Migration[7.2]
  def change
    create_table :spells_character_klasses do |t|
      t.references :spell, null: false, foreign_key: {to_table: :spells}
      t.references :character_klass, null: false, foreign_key: {to_table: :character_klasses}

      t.timestamps

      t.index %i[spell_id character_klass_id], unique: true
    end
  end
end
