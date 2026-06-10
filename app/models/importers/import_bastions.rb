class Importers::ImportBastions < ApplicationOperation
  def call
    Bastion.transaction do
      CSV.foreach(file_path, headers: true, header_converters: :symbol) do |row|
        Bastion.create!(
          title: row[:title],
          original_title: row[:original_title],
          description: row[:description].to_s,
          original_description: row[:original_description].to_s,
          category: row[:category],
          level: row.fetch(:level, 0).to_i,
          published_at: row[:published_at].presence || published_at,
          created_by: created_by
        )
      end
    end

    true
  end

  def initialize(file_path: "db/seeds/data/bastions.csv", created_by: AdminUser.system_user, published_at: nil)
    @file_path = file_path
    @created_by = created_by
    @published_at = published_at
  end

  private

  attr_reader :file_path
  attr_reader :created_by
  attr_reader :published_at
end
