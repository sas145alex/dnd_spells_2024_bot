class WildMagic < ApplicationRecord
  include Mentionable
  include WhoDidItable

  MIN_ROLL = 1
  MAX_ROLL = 100
  DESCRIPTION_FORMAT = "Markdown"

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
