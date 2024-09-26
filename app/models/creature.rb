class Creature < ApplicationRecord
  include Publishable
  include Mentionable
  include PgSearch::Model

  belongs_to :created_by,
    class_name: "AdminUser",
    foreign_key: "created_by_id",
    optional: true
  belongs_to :updated_by,
    class_name: "AdminUser",
    foreign_key: "updated_by_id",
    optional: true
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
    using: :trigram

  before_validation :strip_title

  def self.ransackable_associations(auth_object = nil)
    %w[created_by updated_by responsible]
  end

  def long_description?
    description.size >= DESCRIPTION_LIMIT
  end

  private

  def strip_title
    self.title = title&.strip
  end
end
