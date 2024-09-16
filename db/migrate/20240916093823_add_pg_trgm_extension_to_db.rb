class AddPgTrgmExtensionToDb < ActiveRecord::Migration[7.2]
  def up
    execute "create  extension IF NOT EXISTS pg_trgm;"
  end

  def down
    execute "drop extension IF EXISTS pg_trgm;"
  end
end
