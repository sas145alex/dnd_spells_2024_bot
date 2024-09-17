class CreateCreatures < ActiveRecord::Migration[7.2]
  def change
    create_table :creatures do |t|
      t.references :created_by, index: true, foreign_key: {to_table: :admin_users}
      t.references :updated_by, index: true, foreign_key: {to_table: :admin_users}
      t.references :responsible, index: true, foreign_key: {to_table: :admin_users}

      t.string :title, null: false
      t.string :original_title
      t.string :description, null: false
      t.datetime :published_at

      t.index :title, name: "index_creatures_on_title_gin", using: :gin, opclass: :gin_trgm_ops
      t.index :title, name: "index_creatures_on_title"
      t.index [:published_at], where: "published_at IS NOT NULL"

      t.timestamps
    end
  end
end
