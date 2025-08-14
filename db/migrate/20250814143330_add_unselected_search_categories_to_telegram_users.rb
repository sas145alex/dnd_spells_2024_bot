class AddUnselectedSearchCategoriesToTelegramUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :telegram_users,
      :unselected_search_categories,
      :string,
      array: true,
      default: [],
      null: false
  end
end
