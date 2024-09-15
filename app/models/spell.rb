class Spell < ApplicationRecord
  DESCRIPTION_FORMAT = "MarkdownV2"

  belongs_to :created_by,
             class_name: "AdminUser",
             foreign_key: "created_by_id",
             optional: true
  belongs_to :updated_by,
             class_name: "AdminUser",
             foreign_key: "updated_by_id",
             optional: true

  validates :title, presence: true
  validates :title, length: { minimum: 5, maximum: 150 }, allow_blank: true
  validates :description, presence: true, if: :published?
  validates :description,
            length: { minimum: 5, maximum: 350 },
            if: :published?,
            allow_blank: true

  scope :published, -> { where.not(published_at: nil) }

  def published?
    published_at.present?
  end
end
