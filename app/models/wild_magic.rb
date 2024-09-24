class WildMagic < ApplicationRecord
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

  has_many :mentions,
    class_name: "Mention",
    as: :mentionable,
    dependent: :restrict_with_error

  has_many :mentioned_mentions,
    class_name: "Mention",
    as: :another_mentionable,
    dependent: :restrict_with_error

  accepts_nested_attributes_for :mentions, allow_destroy: true

  validates :description,
    length: {minimum: 5, maximum: 5000},
    allow_blank: true

  scope :ordered, -> { order(roll: :asc) }

  def self.ransackable_associations(auth_object = nil)
    %w[created_by updated_by]
  end
end
