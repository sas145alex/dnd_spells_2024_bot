class MagicItem < ApplicationRecord
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

  enum :category, {
    wand: "wand",
    armor: "armor",
    shield: "shield",
    rod: "rod",
    potion: "potion",
    ring: "ring",
    weapon: "weapon",
    staff: "staff",
    scroll: "scroll",
    magic_item: "magic_item"
  }, default: "other"

  enum :rarity, {
    common: "common",
    uncommon: "uncommon",
    rare: "rare",
    very_rare: "very_rare",
    legendary: "legendary",
    artifact: "artifact",
    vary: "vary"
  }, default: "common"

  enum :attunement, {
    unrequired: "unrequired",
    required: "required",
    magic: "magic",
    special: "special"
  }, default: "unrequired"

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
