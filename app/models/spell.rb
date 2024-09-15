class Spell < ApplicationRecord
  scope :published, -> { where.not(published_at: nil) }
end
