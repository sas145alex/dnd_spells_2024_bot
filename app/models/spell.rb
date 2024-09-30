class Spell < ApplicationRecord
  include Publishable
  include Mentionable
  include WhoDidItable
  include PgSearch::Model

  belongs_to :responsible,
    class_name: "AdminUser",
    foreign_key: "responsible_id",
    optional: true

  validates :title, presence: true
  validates :title, length: {minimum: 3, maximum: 250}, allow_blank: true
  validates :description, presence: true, if: :published?
  validates :description,
    length: {minimum: 5, maximum: 5000},
    if: :published?,
    allow_blank: true

  pg_search_scope :search_by_title,
    against: [:title, :original_title],
    using: {
      tsearch: {dictionary: "russian"}
    }

  scope :ordered, -> { order(title: :asc) }

  before_validation :strip_title
  before_validation :strip_original_title

  def self.ransackable_associations(auth_object = nil)
    %w[created_by updated_by responsible]
  end

  def self.telegram_bot_search(search_input = "", scope: Spell.published, limit: 10)
    complex_search_result_ids = scope.search_by_title(search_input).pluck(:id)
    simple_search_result_ids = scope.where(
      "replace(lower(title), 'ё', 'е') LIKE ? OR replace(lower(original_title), 'ё', 'е') LIKE ?",
      "%#{search_input}%",
      "%#{search_input}%"
    ).pluck(:id)
    ids = (complex_search_result_ids + simple_search_result_ids).uniq
    where(id: ids)
  end

  def long_description?
    description.size >= DESCRIPTION_LIMIT
  end

  private

  def strip_title
    self.title = title&.strip
  end

  def strip_original_title
    self.original_title = original_title&.strip
  end
end
