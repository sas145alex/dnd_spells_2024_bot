class CreateFeedback < ActiveRecord::Migration[7.2]
  def change
    create_table :feedbacks do |t|
      t.bigint :external_user_id, null: true, index: true
      t.text :message, null: false
      t.jsonb :payload, null: false, default: {}

      t.timestamps
    end
  end
end
