class TelegramUser < ApplicationRecord
  has_many :favorites, dependent: :destroy

  scope :active, -> { where(bot_removed_at: nil) }
  scope :not_active, -> { where.not(bot_removed_at: nil) }

  def favorited?(record)
    favorites.exists?(favoritable: record)
  end

  def self.autocomplete_search(input = "")
    return none if input.blank?

    ransack({external_id_eq: input, username_cont: input, m: "or"}).result
  end
end
