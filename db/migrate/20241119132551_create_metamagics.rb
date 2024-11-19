class CreateMetamagics < ActiveRecord::Migration[7.2]
  def change
    create_table :metamagics do |t|
      t.string :title, null: false
      t.string :original_title
      t.text :description, null: false, default: ""
      t.integer :sorcery_points, null: false, default: 1
      t.datetime :published_at

      t.references :created_by, null: true, foreign_key: {to_table: :admin_users}
      t.references :updated_by, null: true, foreign_key: {to_table: :admin_users}

      t.timestamps
    end
  end
end
