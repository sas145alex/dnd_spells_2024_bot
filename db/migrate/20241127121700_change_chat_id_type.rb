class ChangeChatIdType < ActiveRecord::Migration[7.2]
  def up
    change_column :telegram_users, :chat_id, :bigint
  end

  def down
    change_column :telegram_users, :chat_id, :integer
  end
end
