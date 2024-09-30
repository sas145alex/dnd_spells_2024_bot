class RenameCounterInTelegramUsers < ActiveRecord::Migration[7.2]
  def up
    execute("UPDATE telegram_users SET spells_requested_count = 0")
    rename_column :telegram_users, :spells_requested_count, :command_requested_count
  end

  def down
    rename_column :telegram_users, :spells_requested_count, :command_requested_count
  end
end
