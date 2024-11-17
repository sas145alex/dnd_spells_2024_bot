class MessageDistribution < ApplicationRecord
  include WhoDidItable

  validates :title, presence: true
  validates :title, length: {minimum: 3, maximum: 250}, allow_blank: true
  validates :content, presence: true
  validates :content,
    length: {minimum: 5, maximum: 5000},
    allow_blank: true

  before_validation :strip_title

  def self.ransackable_associations(auth_object = nil)
    %w[created_by updated_by category]
  end

  def long_description?
    description.size >= DESCRIPTION_LIMIT
  end

  private

  def strip_title
    self.title = title&.strip
  end
end
