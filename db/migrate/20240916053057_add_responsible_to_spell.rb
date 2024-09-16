class AddResponsibleToSpell < ActiveRecord::Migration[7.2]
  def change
    add_reference :spells,
                  :responsible,
                  index: true,
                  foreign_key: { to_table: :admin_users }
  end
end
