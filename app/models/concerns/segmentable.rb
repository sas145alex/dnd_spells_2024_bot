module Segmentable
  extend ActiveSupport::Concern

  included do
    has_many :segment_items,
      class_name: "Segment",
      as: :resource,
      dependent: :restrict_with_error

    has_many :segment_categories,
      class_name: "Segment",
      as: :attribute_resource,
      dependent: :restrict_with_error

    accepts_nested_attributes_for :segment_items, allow_destroy: true
  end
end
