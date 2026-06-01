class AddAdminToTelegramUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :telegram_users, :admin, :boolean, default: false, null: false
  end
end
