class CreateBastions < ActiveRecord::Migration[8.1]
  def change
    create_table :bastions do |t|
      t.string :title, null: false
      t.string :original_title
      t.text :description, null: false, default: ""
      t.text :original_description, null: false, default: ""
      t.string :category, null: false
      t.integer :level, null: false, default: 0
      t.string :searchable_title, null: false, default: ""
      t.datetime :published_at

      t.references :created_by, null: true, foreign_key: {to_table: :admin_users}
      t.references :updated_by, null: true, foreign_key: {to_table: :admin_users}

      t.timestamps
    end
  end
end
