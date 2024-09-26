class WildMagic < ApplicationRecord
  include Mentionable

  MIN_ROLL = 1
  MAX_ROLL = 100
  DESCRIPTION_FORMAT = "Markdown"

  belongs_to :created_by,
    class_name: "AdminUser",
    foreign_key: "created_by_id",
    optional: true
  belongs_to :updated_by,
    class_name: "AdminUser",
    foreign_key: "updated_by_id",
    optional: true

  validates :description,
    length: {minimum: 5, maximum: 5000},
    allow_blank: true

  scope :ordered, -> { order(roll: :asc) }

  def self.ransackable_associations(auth_object = nil)
    %w[created_by updated_by]
  end

  def self.find_by_roll(roll_value)
    find_by("int4range(roll) @> #{roll_value}")
  end
end
