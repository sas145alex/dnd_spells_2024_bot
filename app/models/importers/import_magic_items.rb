class Importers::ImportMagicItems < ApplicationOperation
  def call
    translated_categories = MagicItem.human_enum_names(:category)
    translated_rarities = MagicItem.human_enum_names(:rarity)
    translated_attunements = MagicItem.human_enum_names(:attunement)
    MagicItem.transaction do
      CSV.foreach(file_path, headers: true, header_converters: :symbol) do |row|
        original_title = preprocess_original_title(row[:original_title])
        category = translated_categories.fetch(row[:category])
        rarity = translated_rarities.fetch(row[:rarity])
        attunement = translated_attunements.fetch(row[:attunement])
        description = preprocess_text(row[:description])
        charges = boolean(row[:charges])
        cursed = boolean(row[:cursed])

        MagicItem.create!(
          title: row[:title],
          original_title: original_title,
          description: description,
          category: category,
          rarity: rarity,
          attunement: attunement,
          price: row[:price],
          charges: charges,
          cursed: cursed,
          published_at: Time.current,
          created_at: row[:created_at] || Time.current,
          updated_at: row[:updated_at] || Time.current,
          created_by: created_by
        )
      end
    end

    true
  end

  def initialize(file_path: "db/seeds/data/mag_items_not_final.csv", created_by: AdminUser.system_user)
    @file_path = file_path
    @created_by = created_by
  end

  private

  attr_reader :file_path
  attr_reader :created_by

  def preprocess_original_title(text)
    text.titleize
  end

  def preprocess_text(text)
    str = text.strip
    str.gsub(/\r\n?/, " ").gsub(/\b-\s\b/, "").strip
  end

  def boolean(value)
    return true if value.is_a?(String) && value.strip.downcase == "да"
    return false if value.is_a?(String) && value.strip.downcase == "нет"
    ActiveRecord::Type::Boolean.new.serialize(value)
  end
end
