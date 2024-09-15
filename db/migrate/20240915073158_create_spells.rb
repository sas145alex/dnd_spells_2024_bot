class CreateSpells < ActiveRecord::Migration[7.2]
  def change
    create_table :spells do |t|
      t.string :title, null: false
      t.string :description, null: false
      t.datetime :published_at

      t.index [:published_at], where: "published_at IS NOT NULL"

      t.timestamps
    end
  end
end
