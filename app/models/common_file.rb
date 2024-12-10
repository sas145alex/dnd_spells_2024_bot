class CommonFile < ApplicationRecord
  ATTACHMENT_CONTENT_TYPES = %i[png jpg jpeg]

  has_one_attached :attachment

  validates :title, presence: true
  validates :attachment,
    attached: true,
    content_type: ATTACHMENT_CONTENT_TYPES,
    size: {less_than: 1.5.megabytes, message: "is too large - max is 1.5mb"}
end
