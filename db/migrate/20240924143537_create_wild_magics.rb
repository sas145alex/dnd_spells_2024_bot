class CreateWildMagics < ActiveRecord::Migration[7.2]
  def change
    create_table :wild_magics do |t|
      t.int4range :roll, null: false
      t.text :description, null: false

      t.references :created_by, index: true, foreign_key: {to_table: :admin_users}
      t.references :updated_by, index: true, foreign_key: {to_table: :admin_users}

      t.timestamps

      t.index [:roll], unique: true
    end
  end
end
