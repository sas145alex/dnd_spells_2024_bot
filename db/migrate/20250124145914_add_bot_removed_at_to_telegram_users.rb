class AddBotRemovedAtToTelegramUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :telegram_users, :bot_removed_at, :datetime
  end
end
