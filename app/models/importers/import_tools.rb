class Importers::ImportTools < ApplicationOperation
  def call
    Tool.transaction do
      CSV.foreach(file_path, headers: true, header_converters: :symbol) do |row|
        Tool.create!(
          title: row[:title],
          original_title: row[:original_title],
          description: row[:description],
          published_at: row[:published_at],
          created_at: row[:created_at],
          updated_at: row[:updated_at],
          created_by: created_by
        )
      end
    end

    true
  end

  def initialize(file_path: "db/seeds/data/tools-2024-09-27.csv", created_by: AdminUser.system_user)
    @file_path = file_path
    @created_by = created_by
  end

  private

  attr_reader :file_path
  attr_reader :created_by
end