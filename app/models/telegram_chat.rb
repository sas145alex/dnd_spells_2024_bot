class TelegramChat < ApplicationRecord
  scope :active, -> { where(bot_removed_at: nil) }
  scope :not_active, -> { where.not(bot_removed_at: nil) }
end
