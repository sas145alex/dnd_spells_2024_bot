class CommonFile < ApplicationRecord
  mount_uploader :attachment, CommonFileUploader

  validates :title, presence: true
end
