class AddDescriptionSizeToCreatures < ActiveRecord::Migration[8.0]
  def up
    add_column :creatures, :description_size, :integer, null: false, default: 0
    add_column :creatures, :original_description_size, :integer, null: false, default: 0

    fill_counters
  end

  def down
    remove_column :creatures, :description_size, null: false, default: 0
    remove_column :creatures, :original_description_size, null: false, default: 0
  end

  private

  def fill_counters
    sql = <<~SQL.squish
      UPDATE creatures 
      SET description_size = length(description), original_description_size = length(original_description)
      WHERE 1=1
    SQL
    execute(sql)
  end
end
