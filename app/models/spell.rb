class Spell < ApplicationRecord
  include Publishable
  include PgSearch::Model

  DESCRIPTION_FORMAT = "Markdown"
  DESCRIPTION_LIMIT = 4096

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

  has_many :mentions,
    class_name: "Mention",
    as: :mentionable,
    dependent: :restrict_with_error

  has_many :mentioned_mentions,
    class_name: "Mention",
    as: :another_mentionable,
    dependent: :restrict_with_error

  accepts_nested_attributes_for :mentions, allow_destroy: true

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
      tsearch: {dictionary: "english"},
      trigram: {
        only: [:title]
      }
    }

  scope :published, -> { where.not(published_at: nil) }
  scope :not_published, -> { where(published_at: nil) }

  before_validation :chomp_title
  before_validation :chomp_original_title

  def self.ransackable_associations(auth_object = nil)
    %w[created_by updated_by responsible]
  end

  def long_description?
    description.size >= DESCRIPTION_LIMIT
  end

  private

  def chomp_title
    self.title = title&.chomp
  end

  def chomp_original_title
    self.original_title = original_title&.chomp
  end
end
