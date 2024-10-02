class Segment < ApplicationRecord
  belongs_to :resource, polymorphic: true
  belongs_to :attribute_resource, polymorphic: true
end
