class CreateCharacterKlasses < ActiveRecord::Migration[7.2]
  def change
    create_table :character_klasses do |t|
      t.string :title, null: false
      t.string :original_title
      t.text :description, null: false, default: ""

      t.references :parent_klass, null: true, foreign_key: {to_table: :character_klasses}
      t.references :created_by, null: true, foreign_key: {to_table: :admin_users}
      t.references :updated_by, null: true, foreign_key: {to_table: :admin_users}

      t.timestamps
    end
  end
end
