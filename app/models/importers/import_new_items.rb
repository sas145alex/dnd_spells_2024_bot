class Importers::ImportNewItems < ApplicationOperation
  def call
    translated_enums = EquipmentItem.human_enum_names(:item_type)
    EquipmentItem.transaction do
      CSV.foreach(file_path, headers: true, header_converters: :symbol) do |row|
        item_type = translated_enums.fetch(row[:category])
        description = row[:description].gsub(/\r\n?/, " ").gsub(/\b-\s\b/, "")
        EquipmentItem.create!(
          title: row[:title],
          original_title: row[:original_title],
          description: description,
          weight: row[:weight],
          price: row[:price],
          item_type: item_type,
          published_at: Time.current,
          created_at: row[:created_at] || Time.current,
          updated_at: row[:updated_at] || Time.current,
          created_by: created_by
        )
      end
    end

    true
  end

  def initialize(file_path: "db/seeds/data/new_items.csv", created_by: AdminUser.system_user)
    @file_path = file_path
    @created_by = created_by
  end

  private

  attr_reader :file_path
  attr_reader :created_by
end
