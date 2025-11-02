class RenameInfusionToPsionicPower < ActiveRecord::Migration[8.0]
  def change
    rename_table :infusions, :psionic_powers
  end
end
