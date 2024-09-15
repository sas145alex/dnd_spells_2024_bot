class CreateSpells < ActiveRecord::Migration[7.2]
  def change
    create_table :spells do |t|
      t.references :created_by, index: true, foreign_key: {to_table: :admin_users}
      t.references :updated_by, index: true, foreign_key: {to_table: :admin_users}

      t.string :title, null: false
      t.string :description, null: false
      t.datetime :published_at

      t.index [:published_at], where: "published_at IS NOT NULL"

      t.timestamps
    end
  end
end
