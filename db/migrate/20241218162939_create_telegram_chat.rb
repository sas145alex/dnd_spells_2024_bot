class CreateTelegramChat < ActiveRecord::Migration[7.2]
  def change
    create_table :telegram_chats do |t|
      t.bigint :external_id, null: false
      t.datetime :last_seen_at
      t.datetime :bot_added_at
      t.datetime :bot_removed_at
      t.integer :command_requested_count, null: false, default: 0

      t.index :external_id, unique: true

      t.timestamps
    end
  end
end
