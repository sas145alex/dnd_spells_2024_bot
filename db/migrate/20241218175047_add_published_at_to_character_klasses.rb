class AddPublishedAtToCharacterKlasses < ActiveRecord::Migration[7.2]
  def up
    add_column :character_klasses, :published_at, :datetime
    sql = <<~SQL.squish
      UPDATE character_klasses 
      SET published_at = now()
      WHERE 1=1
    SQL
    execute(sql)
  end

  def down
    remove_column :character_klasses, :published_at, :datetime
  end
end
