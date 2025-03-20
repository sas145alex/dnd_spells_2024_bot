module Multisearchable
  extend ActiveSupport::Concern

  def self.used_klasses
    ApplicationRecord.descendants.select { |c| c.included_modules.include?(self) }
  end

  def self.regenerate_all_multisearchables!
    ApplicationRecord.transaction do
      used_klasses.each do |klass|
        PgSearch::Multisearch.rebuild(klass, transactional: false)
      end
    end
  end

  def self.regenerate_all_searchable_columns!
    ApplicationRecord.transaction do
      used_klasses.each do |klass|
        klass.find_each do |record|
          record.regenerate_searchable_columns!
        end
      end
    end
  end

  def self.format(*strings)
    strings.map do |item|
      item.to_s.downcase.strip.gsub(/\s+/, " ").tr("ё", "е")
    end.join(" ").strip
  end

  def self.search(raw_input, scope: PgSearch::Document.all)
    search_input = format(raw_input)
    complex_search_result_ids = scope.search(search_input)
      .pluck(:id)
    simple_search_result_ids = scope.where("content LIKE ?", "%#{search_input}%")
      .pluck(:id)
    ids = (complex_search_result_ids + simple_search_result_ids).uniq
    PgSearch::Document.order(:searchable_type).where(id: ids)
  end

  included do
    include PgSearch::Model

    before_validation :regenerate_searchable_columns

    multisearchable against: [:searchable_title],
      using: {
        tsearch: {dictionary: "russian"}
      },
      additional_attributes: ->(record) { {published: record.published?} }

    def regenerate_searchable_columns
      self.searchable_title = Multisearchable.format(title, original_title)
    end

    def regenerate_searchable_columns!
      update!(searchable_title: Multisearchable.format(title, original_title))
    end
  end
end
