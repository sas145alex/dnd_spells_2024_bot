class CreateSegments < ActiveRecord::Migration[7.2]
  def change
    create_table :segments do |t|
      t.references :resource, polymorphic: true, index: false
      t.references :attribute_resource, polymorphic: true, index: true

      t.timestamps

      t.index [:resource_id, :resource_type, :attribute_resource_type, :attribute_resource_id],
        unique: true,
        name: "index_segments_on_resource"
    end
  end
end
