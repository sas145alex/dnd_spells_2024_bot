class Feat < ApplicationRecord
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

  validates :title, presence: true
  validates :title, length: {minimum: 3, maximum: 250}, allow_blank: true
  validates :description,
    length: {minimum: 5, maximum: 5000},
    if: :published?,
    allow_blank: true
  validates :category, presence: true

  scope :ordered, -> { order(title: :asc) }

  before_validation :strip_title
  before_validation :strip_original_title

  enum :category, {
    general: "general",
    origin: "origin",
    fighting_style: "fighting_style",
    epic_boon: "epic_boon"
  }

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

  def strip_original_title
    self.original_title = original_title&.strip
  end
end
