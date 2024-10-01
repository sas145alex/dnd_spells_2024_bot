class EquipmentItem < ApplicationRecord
  include Publishable
  include Mentionable
  include WhoDidItable

  validates :title, presence: true
  validates :title, length: {minimum: 3, maximum: 250}, allow_blank: true
  validates :description, presence: true, if: :published?
  validates :description,
    length: {minimum: 5, maximum: 5000},
    if: :published?,
    allow_blank: true

  scope :ordered, -> { order(title: :asc) }

  before_validation :strip_title
  before_validation :strip_original_title

  enum :item_type, {
    simple_melee: "simple_melee",
    simple_ranged: "simple_ranged",
    martial_melee: "martial_melee",
    martial_ranged: "martial_ranged",
    light_armor: "light_armor",
    medium_armor: "medium_armor",
    heavy_armor: "heavy_armor",
    shield: "shield"
  }

  def self.ransackable_associations(auth_object = nil)
    %w[created_by updated_by]
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
