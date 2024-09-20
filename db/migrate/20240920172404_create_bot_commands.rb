class CreateBotCommands < ActiveRecord::Migration[7.2]
  def change
    create_table :bot_commands do |t|
      t.string :title, null: false
      t.text :description
      t.jsonb :data, null: false, default: {}

      t.timestamps

      t.index [:title], unique: true
    end
  end
end
