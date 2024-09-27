module WhoDidItable
  extend ActiveSupport::Concern

  included do
    belongs_to :created_by,
      class_name: "AdminUser",
      foreign_key: "created_by_id",
      optional: true
    belongs_to :updated_by,
      class_name: "AdminUser",
      foreign_key: "updated_by_id",
      optional: true
  end
end
