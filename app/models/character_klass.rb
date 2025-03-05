class CharacterKlass < ApplicationRecord
  include Multisearchable
  include Publishable
  include Mentionable
  include Segmentable
  include WhoDidItable

  belongs_to :parent_klass,
    foreign_key: "parent_klass_id",
    class_name: "CharacterKlass",
    optional: true

  has_many :spells_character_klasses,
    class_name: "SpellsCharacterKlass",
    foreign_key: "character_klass_id"
  has_many :spells,
    class_name: "Spell",
    through: :spells_character_klasses

  validates :title, presence: true
  validates :title, length: {minimum: 3, maximum: 250}, allow_blank: true
  validates :description, presence: true, allow_blank: true
  validates :description,
    length: {minimum: 0, maximum: 5000},
    allow_blank: true

  scope :ordered, -> { order(title: :asc) }
  scope :base_klasses, -> { where(parent_klass: nil) }
  scope :subklasses, -> { where.not(parent_klass: nil) }

  before_validation :strip_title
  before_validation :strip_original_title
  before_validation :strip_description

  def self.ransackable_associations(auth_object = nil)
    %w[created_by updated_by parent_klass]
  end

  def long_description?
    description.size >= DESCRIPTION_LIMIT
  end

  def base_klass?
    parent_klass_id.nil?
  end

  def use_invocations?
    main_character_klass.title == "Колдун" || main_character_klass.original_title == "Warlock"
  end

  def use_metamagic?
    main_character_klass.title == "Чародей" || main_character_klass.original_title == "Sorcerer"
  end

  def use_maneuvers?
    title == "Мастер боевых искусств" || original_title == "Battle Master"
  end

  def use_infusions?
    # wait for release of Artificer and see if Infusion is needed
    false
  end

  def has_spells?
    klass_ids = base_klass? ? [id] : [id, parent_klass_id]
    SpellsCharacterKlass.where(character_klass_id: klass_ids).exists?
  end

  def use_parent_description?
    return false if base_klass?

    description.size == 0
  end

  def main_character_klass
    @main_character_klass ||= base_klass? ? self : parent_klass
  end

  private

  def strip_title
    self.title = title&.strip
  end

  def strip_original_title
    self.original_title = original_title&.strip
  end

  def strip_description
    self.description = description.to_s.strip
  end
end
