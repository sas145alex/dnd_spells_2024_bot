class AddChatIdToTelegramUser < ActiveRecord::Migration[7.2]
  def change
    add_column :telegram_users, :chat_id, :integer
    add_index :telegram_users, :chat_id
  end
end
