class AddEditionSourceToOrigins < ActiveRecord::Migration[8.1]
  def change
    add_column :origins, :edition_source, :string, null: false, default: "MM25"
  end
end
