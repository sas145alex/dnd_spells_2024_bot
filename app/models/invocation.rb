class Invocation < ApplicationRecord
  include Publishable
  include Mentionable
  include WhoDidItable

  validates :title, presence: true
  validates :title, length: {minimum: 3, maximum: 250}, allow_blank: true
  validates :description, presence: true
  validates :description,
    length: {minimum: 0, maximum: 5000},
    allow_blank: true

  scope :ordered, -> { order(level: :asc, title: :asc) }

  before_validation :strip_title
  before_validation :strip_original_title

  def self.ransackable_associations(auth_object = nil)
    %w[created_by updated_by]
  end

  def long_description?
    description.size >= DESCRIPTION_LIMIT
  end

  private

  def strip_title
    self.title = title&.strip
  end

  def strip_original_title
    self.original_title = original_title&.strip
  end
end
