class Spell < ApplicationRecord
  include PgSearch::Model

  DESCRIPTION_FORMAT = "Markdown"

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
    against: :title,
    using: :trigram

  scope :published, -> { where.not(published_at: nil) }
  scope :not_published, -> { where(published_at: nil) }

  def self.ransackable_associations(auth_object = nil)
    %w[created_by updated_by responsible]
  end

  def published?
    published_at.present?
  end

  def publish!
    update!(published_at: Time.current)
  end

  def unpublish!
    update!(published_at: nil)
  end
end
