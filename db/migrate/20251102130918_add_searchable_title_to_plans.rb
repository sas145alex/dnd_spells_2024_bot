class AddSearchableTitleToPlans < ActiveRecord::Migration[8.0]
  def change
    add_column :plans, :searchable_title, :string, null: false, default: ""
    add_column :psionic_powers, :searchable_title, :string, null: false, default: ""
    add_column :arcane_shots, :searchable_title, :string, null: false, default: ""
  end
end
