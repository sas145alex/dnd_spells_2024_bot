class CreateMagicItem < ActiveRecord::Migration[7.2]
  def change
    create_table :magic_items do |t|
      t.string :title, null: false
      t.string :original_title, null: false, default: ""
      t.text :description, null: false, default: ""
      t.string :category, null: false, default: "other"
      t.string :rarity, null: false, default: "common"
      t.string :attunement, null: false, default: "unrequired"
      t.boolean :charges, null: false, default: false
      t.boolean :cursed, null: false, default: false
      t.string :price, null: false, default: ""

      t.datetime :published_at

      t.references :created_by, null: true, foreign_key: {to_table: :admin_users}
      t.references :updated_by, null: true, foreign_key: {to_table: :admin_users}

      t.timestamps
    end
  end
end
