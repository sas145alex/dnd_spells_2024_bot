class Importers::Local::ImportCreaturesE5Tools < ApplicationOperation
  def call
    Creature.transaction do
      CSV.foreach(file_path, headers: true, header_converters: :symbol) do |row|
        parsed_row = ParsedRow.new(row)

        Creature.create!(
          created_by: created_by,
          title: parsed_row.title,
          original_title: parsed_row.original_title,
          description: parsed_row.description,
          original_description: parsed_row.original_description,
          published_at: nil,
          created_at: nil,
          updated_at: nil,
          edition_source: parsed_row.edition_source,
          creature_size: parsed_row.creature_size,
          creature_type: parsed_row.creature_type,
          creature_subtype: parsed_row.creature_subtype,
          armor_class: parsed_row.armor_class,
          hit_points: parsed_row.hit_points,
          hit_points_formula: parsed_row.hit_points_formula,
          challenge_rating: parsed_row.challenge_rating,
          import_source: parsed_row.import_source
        )
      end
    end

    true
  end

  def initialize(file_path: "db/seeds/data/Bestiary.csv", created_by: AdminUser.system_user)
    @file_path = file_path
    @created_by = created_by
  end

  private

  attr_reader :file_path
  attr_reader :created_by
end
