class CreateGlossaryCategories < ActiveRecord::Migration[7.2]
  def change
    create_table :glossary_categories do |t|
      t.string :title, null: false
      t.string :original_title
      t.references :parent_category, null: true, foreign_key: {to_table: :glossary_categories}

      t.timestamps
    end
  end
end
