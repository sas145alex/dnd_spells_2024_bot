class CharacterKlassAbility < ApplicationRecord
  include Multisearchable
  include Publishable
  include Mentionable
  include WhoDidItable

  belongs_to :character_klass,
    foreign_key: "character_klass_id",
    class_name: "CharacterKlass",
    optional: false

  validates :title, presence: true
  validates :title, length: {minimum: 3, maximum: 250}, allow_blank: true
  validates :description, presence: true
  validates :description,
    length: {minimum: 0, maximum: 5000},
    allow_blank: true

  scope :ordered, -> { order(title: :asc) }

  before_validation :normalize_levels
  before_validation :strip_title
  before_validation :strip_original_title

  def self.ransackable_associations(auth_object = nil)
    %w[created_by updated_by character_klass]
  end

  def long_description?
    description.size >= DESCRIPTION_LIMIT
  end

  private

  def normalize_levels
    self.levels = levels&.compact
  end

  def strip_title
    self.title = title&.strip
  end

  def strip_original_title
    self.original_title = original_title&.strip
  end
end
