class CreateMessageDistributions < ActiveRecord::Migration[7.2]
  def change
    create_table :message_distributions do |t|
      t.string :title, null: false
      t.text :content, null: false
      t.datetime :last_sent_at

      t.references :created_by, index: true, foreign_key: {to_table: :admin_users}
      t.references :updated_by, index: true, foreign_key: {to_table: :admin_users}

      t.timestamps
    end
  end
end
