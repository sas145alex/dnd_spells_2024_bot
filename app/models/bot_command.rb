class BotCommand < ApplicationRecord
  ABOUT_ID = "about"
  TOOL_ID = "tool"

  validates :title, presence: true
  validates :title, length: {minimum: 3, maximum: 250}, allow_blank: true
  validates :title, uniqueness: true

  before_validation :strip_title

  def self.about
    @about ||= find_by!(title: ABOUT_ID)
  end

  def self.tool
    find_by!(title: TOOL_ID)
  end

  def long_description?
    description.size >= DESCRIPTION_LIMIT
  end

  def tool?
    title == TOOL_ID
  end

  private

  def strip_title
    self.title = title&.strip
  end
end
