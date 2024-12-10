class CreateCommonFile < ActiveRecord::Migration[7.2]
  def change
    create_table :common_files do |t|
      t.string :title, null: false
      t.jsonb :attachment, null: false

      t.timestamps
    end
  end
end
