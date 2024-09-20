class CreateTelegramUser < ActiveRecord::Migration[7.2]
  def change
    create_table :telegram_users do |t|
      t.bigint :external_id, null: false
      t.datetime :last_seen_at
      t.integer :spells_requested_count, null: false, default: 0

      t.index :external_id, unique: true
      t.index :last_seen_at

      t.timestamps
    end
  end
end
