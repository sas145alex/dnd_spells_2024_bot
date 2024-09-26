class Services::ImportGlossaryItemsMd < ApplicationOperation
  def call
    title = ""
    description = ""

    objects = []
    File.readlines(file_path).each do |line|
      if header?(line) && title.present?
        objects << {title: title, description: description.strip}
        title = ""
        description = ""
      end

      if header?(line)
        title = line.gsub(/#+/, "").strip
      else
        description.concat(line)
      end
    end

    GlossaryItem.transaction do
      objects.each do |attrs|
        GlossaryItem.create!(
          title: attrs[:title],
          description: attrs[:description],
          category: category,
          created_by: created_by
        )
      end
    end

    true
  end

  def initialize(file_path: "db/seeds/data/glossary_output.md", created_by: AdminUser.system_user)
    @file_path = file_path
    @created_by = created_by
  end

  private

  attr_reader :file_path
  attr_reader :created_by

  def header?(line)
    line.start_with?("#")
  end

  def category
    @category ||= GlossaryCategory.default_category
  end
end
