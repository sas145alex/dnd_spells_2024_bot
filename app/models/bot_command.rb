class BotCommand < ApplicationRecord
  include Mentionable

  START_ID = "start"
  ABOUT_ID = "about"
  TOOL_ID = "tool"
  CRAFTING_ID = "crafting"
  ORIGIN_ID = "origin"
  FEEDBACK_ID = "feedback"

  validates :title, presence: true
  validates :title, length: {minimum: 3, maximum: 250}, allow_blank: true
  validates :title, uniqueness: true

  before_validation :strip_title

  scope :ordered, -> { order(title: :asc) }

  def self._memoized_commands
    @memoized_commands ||= all.to_a
  end

  def self._reset_memoized_commands
    return unless defined?(@memoized_commands)
    remove_instance_variable(:@memoized_commands)
  end

  def self.memoized_search(title:)
    _memoized_commands.find { it.title == title }
  end

  def self.start
    memoized_search(title: START_ID)
  end

  def self.about
    memoized_search(title: ABOUT_ID)
  end

  def self.tool
    memoized_search(title: TOOL_ID)
  end

  def self.crafting
    memoized_search(title: CRAFTING_ID)
  end

  def self.origin
    memoized_search(title: ORIGIN_ID)
  end

  def self.feedback
    memoized_search(title: FEEDBACK_ID)
  end

  def long_description?
    description.size >= DESCRIPTION_LIMIT
  end

  private

  def strip_title
    self.title = title&.strip
  end
end
