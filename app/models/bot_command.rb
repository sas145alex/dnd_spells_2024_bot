class BotCommand < ApplicationRecord
  include Mentionable

  START_ID = "start"
  ABOUT_ID = "about"
  TOOL_ID = "tool"
  CRAFTING_ID = "crafting"
  ORIGIN_ID = "origin"

  validates :title, presence: true
  validates :title, length: {minimum: 3, maximum: 250}, allow_blank: true
  validates :title, uniqueness: true

  before_validation :strip_title

  scope :ordered, -> { order(title: :asc) }

  def self.start
    find_by!(title: START_ID)
  end

  def self.about
    find_by!(title: ABOUT_ID)
  end

  def self.tool
    find_by!(title: TOOL_ID)
  end

  def self.crafting
    find_by!(title: CRAFTING_ID)
  end

  def self.origin
    find_by!(title: ORIGIN_ID)
  end

  def long_description?
    description.size >= DESCRIPTION_LIMIT
  end

  private

  def strip_title
    self.title = title&.strip
  end
end
