class AddDistributionTracking < ActiveRecord::Migration[8.1]
  def change
    change_table :message_distributions, bulk: true do |t|
      t.string :status, null: false, default: "draft"

      t.boolean :send_to_users, null: false, default: true
      t.boolean :send_to_chats, null: false, default: false
      t.boolean :only_active, null: false, default: true
      t.datetime :active_since
      t.integer :min_command_count

      t.integer :recipients_count, null: false, default: 0
      t.integer :delivered_count, null: false, default: 0
      t.integer :failed_count, null: false, default: 0

      t.datetime :started_at
      t.datetime :finished_at

      t.remove :last_sent_at, type: :datetime
    end

    create_table :message_deliveries do |t|
      t.references :message_distribution, null: false, foreign_key: true, index: true
      t.references :recipient, polymorphic: true, null: false
      t.bigint :external_id, null: false

      t.string :status, null: false, default: "pending"
      t.string :error_reason
      t.text :error_message
      t.datetime :sent_at

      t.timestamps
    end

    add_index :message_deliveries, [:message_distribution_id, :status]
    add_index :message_deliveries,
      [:message_distribution_id, :recipient_type, :recipient_id],
      unique: true,
      name: "index_message_deliveries_on_distribution_and_recipient"
  end
end
