class CreateFavorites < ActiveRecord::Migration[8.1]
  def change
    create_table :favorites do |t|
      t.references :telegram_user, null: false, foreign_key: true
      t.references :favoritable, null: false, polymorphic: true

      t.timestamps
    end

    add_index :favorites,
      [:telegram_user_id, :favoritable_type, :favoritable_id],
      unique: true,
      name: "index_favorites_uniqueness"
  end
end
