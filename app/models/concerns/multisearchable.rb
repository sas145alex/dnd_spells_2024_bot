module Multisearchable
  extend ActiveSupport::Concern

  def self.used_klasses
    ApplicationRecord.descendants.select { |c| c.included_modules.include?(self) }
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

  included do
    before_validation :regenerate_searchable_columns, if: :fill_searchable_fields?

    def regenerate_searchable_columns
      self.searchable_title = Multisearchable.format(title, original_title)
    end

    def regenerate_searchable_columns!
      update!(searchable_title: Multisearchable.format(title, original_title))
    end
  end

  private

  def fill_searchable_fields?
    return false if searchable_title_changed?

    title_changed? || original_title_changed?
  end
end
