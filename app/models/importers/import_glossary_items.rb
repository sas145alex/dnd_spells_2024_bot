class Importers::ImportGlossaryItems < ApplicationOperation
  def call
    GlossaryItem.transaction do
      CSV.foreach(file_path, headers: true, header_converters: :symbol) do |row|
        GlossaryItem.create!(
          title: row[:title],
          original_title: row[:original_title],
          description: row[:description],
          published_at: Time.current,
          created_at: row[:created_at],
          updated_at: row[:updated_at],
          category: category,
          created_by: created_by
        )
      end
    end

    true
  end

  def initialize(file_path: "db/seeds/data/glossary-items_2024_09_26.csv", created_by: AdminUser.system_user)
    @file_path = file_path
    @created_by = created_by
  end

  private

  attr_reader :file_path
  attr_reader :created_by

  def category
    @category ||= GlossaryCategory.default_category
  end
end
