class Bastion < ApplicationRecord
  include Multisearchable
  include Publishable
  include Mentionable
  include WhoDidItable

  # construction = Постройки, modification = Модификации (both basic facilities);
  # leveling = специализированные, gained at a character level (see #level).
  enum :category, {
    construction: "construction",
    modification: "modification",
    leveling: "leveling"
  }

  validates :title, presence: true
  validates :title, length: {minimum: 3, maximum: 250}, allow_blank: true
  validates :description, presence: true
  validates :description,
    length: {minimum: 0, maximum: 5000},
    allow_blank: true
  validates :category, presence: true
  # level is 0 for basic facilities (construction/modification) and the unlock level
  # (5/9/13/17) for specialized ones.
  validates :level, numericality: {greater_than: 0}, if: :leveling?
  validates :level, numericality: {equal_to: 0}, unless: :leveling?

  scope :ordered, -> { order(title: :asc) }

  before_validation :strip_title
  before_validation :strip_original_title

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
