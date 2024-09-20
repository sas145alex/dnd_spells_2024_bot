class BotCommand < ApplicationRecord
  ABOUT_ID = "about"
  DESCRIPTION_FORMAT = "Markdown"
  DESCRIPTION_LIMIT = 4096

  validates :title, presence: true
  validates :title, length: {minimum: 3, maximum: 250}, allow_blank: true
  validates :title, uniqueness: true

  before_validation :chomp_title

  def self.about
    @about ||= find_by(title: ABOUT_ID)
  end

  def long_description?
    description.size >= DESCRIPTION_LIMIT
  end

  private

  def chomp_title
    self.title = title&.chomp
  end
end
