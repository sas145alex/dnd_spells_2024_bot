class Importers::ImportCreatures < ApplicationOperation
  def call
    Creature.transaction do
      CSV.foreach(file_path, headers: true, header_converters: :symbol) do |row|
        Creature.create!(
          title: row[:title],
          original_title: row[:original_title],
          description: description(row[:description]),
          published_at: row[:published_at],
          created_at: row[:created_at],
          updated_at: row[:updated_at],
          created_by: created_by,
          edition_source: row[:edition_source] || :player_handbook_2024,
          import_source: row[:import_source] || import_source,
          creature_type: row[:creature_type],
          creature_subtype: row[:creature_subtype],
          challenge_rating: row[:challenge_rating],
          armor_class: row[:armor_class],
          hit_points: row[:hit_points],
          hit_points_formula: row[:hit_points_formula],
          creature_size: row[:creature_size],
          original_description: row[:original_description]
        )
      end
    end

    true
  end

  def initialize(
    file_path: "db/seeds/data/translated_creatures_from_e5tools_unformatted.csv",
    created_by: AdminUser.system_user,
    import_source: "phb24_manual_transfer"
  )
    @file_path = file_path
    @created_by = created_by
    @import_source = import_source
  end

  private

  attr_reader :file_path
  attr_reader :created_by
  attr_reader :import_source

  def description(text)
    formatted_text = text
      .gsub(/\|.*броска\s+\|/, "| --- | -- | -- | Сп |")
      .gsub(/\|[-|]+\|\n/, "")
      .gsub("  \n", "\n")
      .gsub(/##\s*(?<h2>.*)\n/, "**\\k<h2>**\n")

    lines = []
    formatted_text.each_line do |line|
      lines << if line.start_with?(/\|\s+\p{Cyrillic}{3}/)
        line.squeeze(" ")
      else
        line
      end
    end
    lines.join
  end
end
