class Services::ImportWildMagics < ApplicationOperation
  def call
    WildMagic.transaction do
      CSV.foreach(file_path, headers: true, header_converters: :symbol) do |row|
        roll_boundaries = row[:roll].split("...").map(&:to_i)
        roll = Range.new(*roll_boundaries, true)
        WildMagic.create!(
          roll: roll,
          description: row[:description],
          created_at: row[:created_at],
          updated_at: row[:updated_at],
          created_by: created_by
        )
      end
    end

    true
  end

  def initialize(file_path: "db/seeds/data/wild_magics_2024_09_24.csv", created_by: AdminUser.system_user)
    @file_path = file_path
    @created_by = created_by
  end

  private

  attr_reader :file_path
  attr_reader :created_by
end
