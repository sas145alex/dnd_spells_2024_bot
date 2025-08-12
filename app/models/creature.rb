class Creature < ApplicationRecord
  include Multisearchable
  include Publishable
  include Mentionable
  include WhoDidItable
  include PgSearch::Model

  belongs_to :responsible,
    class_name: "AdminUser",
    optional: true

  validates :title, presence: true
  validates :title, length: {minimum: 3, maximum: 250}, allow_blank: true
  validates :description, presence: true, if: :published?
  validates :description,
    length: {minimum: 5, maximum: 5000},
    if: :published?,
    allow_blank: true

  before_validation :strip_title
  before_validation :recalculate_description_size

  scope :ordered, -> { order(title: :asc) }

  enum :creature_type, {
    unknown: "unknown",
    vary: "vary",
    aberration: "aberration",
    beast: "beast",
    celestial: "celestial",
    construct: "construct",
    dragon: "dragon",
    elemental: "elemental",
    fey: "fey",
    fiend: "fiend",
    giant: "giant",
    humanoid: "humanoid",
    monstrosity: "monstrosity",
    ooze: "ooze",
    plant: "plant",
    undead: "undead"
  }, prefix: :type

  enum :creature_size, {
    unknown: "unknown",
    vary: "vary",
    tiny: "tiny",
    small: "small",
    medium: "medium",
    large: "large",
    huge: "huge",
    gargantuan: "gargantuan"
  }, prefix: :size

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

  def recalculate_description_size
    self.description_size = description&.size || 0
    self.original_description_size = original_description&.size || 0
  end
end
