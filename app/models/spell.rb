class Spell < ApplicationRecord
  LEVELS = (0..9)

  include Publishable
  include Mentionable
  include WhoDidItable
  include PgSearch::Model

  belongs_to :responsible,
    class_name: "AdminUser",
    foreign_key: "responsible_id",
    optional: true
  has_many :spells_character_klasses,
    class_name: "SpellsCharacterKlass",
    foreign_key: "spell_id"
  has_many :character_klasses,
    class_name: "CharacterKlass",
    through: :spells_character_klasses

  accepts_nested_attributes_for :spells_character_klasses, allow_destroy: true

  validates :title, presence: true
  validates :title, length: {minimum: 3, maximum: 250}, allow_blank: true
  validates :description, presence: true, if: :published?
  validates :description,
    length: {minimum: 5, maximum: 5000},
    if: :published?,
    allow_blank: true
  validates :level, inclusion: {in: LEVELS}

  pg_search_scope :search_by_title,
    against: [:title, :original_title],
    using: {
      tsearch: {dictionary: "russian"}
    }

  scope :ordered, -> { order(title: :asc) }

  before_validation :strip_title
  before_validation :strip_original_title

  enum :school, {
    abjuration: "abjuration",
    conjuration: "conjuration",
    divination: "divination",
    enchantment: "enchantment",
    evocation: "evocation",
    illusion: "illusion",
    necromancy: "necromancy",
    transmutation: "transmutation"
  }

  enum :casting_time, {
    action: "action",
    bonus_action: "bonus_action",
    reaction: "reaction"
  }

  def self.ransackable_associations(auth_object = nil)
    %w[created_by updated_by responsible character_klasses]
  end

  def self.telegram_bot_search(search_input = "", scope: Spell.published, limit: 10)
    complex_search_result_ids = scope.search_by_title(search_input).pluck(:id)
    simple_search_result_ids = scope.where(
      "replace(lower(title), 'ё', 'е') LIKE ? OR replace(lower(original_title), 'ё', 'е') LIKE ?",
      "%#{search_input}%",
      "%#{search_input}%"
    ).pluck(:id)
    ids = (complex_search_result_ids + simple_search_result_ids).uniq
    where(id: ids)
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
