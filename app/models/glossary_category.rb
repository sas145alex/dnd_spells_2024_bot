class GlossaryCategory < ApplicationRecord
  DEFAULT_CATEGORY_ID = 0

  belongs_to :parent_category,
    class_name: "GlossaryCategory",
    optional: true

  validates :title, presence: true

  def self.default_category
    find(DEFAULT_CATEGORY_ID)
  end

  def self.ransackable_associations(auth_object = nil)
    %w[parent_category]
  end

  scope :published, -> { where.not(id: DEFAULT_CATEGORY_ID).where(parent_category_id: nil) }
  scope :ordered, -> { order(title: :asc) }
end
