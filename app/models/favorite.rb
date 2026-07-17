class Favorite < ApplicationRecord
  belongs_to :telegram_user
  belongs_to :favoritable, polymorphic: true

  validates :favoritable_id, uniqueness: {scope: [:telegram_user_id, :favoritable_type]}
end
