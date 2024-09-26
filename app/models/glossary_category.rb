class GlossaryCategory < ApplicationRecord
  DEFAULT_CATEGORY_ID = 0

  belongs_to :parent_category,
    class_name: "GlossaryCategory",
    optional: true

  has_many :subcategories,
    class_name: "GlossaryCategory",
    foreign_key: :parent_category_id
  has_many :items,
    class_name: "GlossaryItem",
    foreign_key: :category_id

  validates :title, presence: true

  def self.default_category
    find(DEFAULT_CATEGORY_ID)
  end

  def self.ransackable_associations(auth_object = nil)
    %w[parent_category]
  end

  scope :top_level, -> { where(parent_category_id: nil) }
  scope :published, -> { where.not(id: DEFAULT_CATEGORY_ID) }
  scope :ordered, -> { order(title: :asc) }

  def top_level?
    parent_category_id.nil?
  end
end
