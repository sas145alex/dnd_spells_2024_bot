class CreateMentions < ActiveRecord::Migration[7.2]
  def change
    create_table :mentions do |t|
      t.references :mentionable, polymorphic: true, index: false
      t.references :another_mentionable, polymorphic: true, index: true

      t.timestamps

      t.index [:mentionable_id, :mentionable_type, :another_mentionable_type, :another_mentionable_id],
        unique: true,
        name: "index_mentions_on_mentionable"
    end
  end
end
