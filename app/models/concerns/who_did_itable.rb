module WhoDidItable
  extend ActiveSupport::Concern

  included do
    belongs_to :created_by,
      class_name: "AdminUser",
      optional: true
    belongs_to :updated_by,
      class_name: "AdminUser",
      optional: true
  end
end
