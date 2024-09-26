module Mentionable
  extend ActiveSupport::Concern

  included do
    has_many :mentions,
      class_name: "Mention",
      as: :mentionable,
      dependent: :restrict_with_error

    has_many :mentioned_mentions,
      class_name: "Mention",
      as: :another_mentionable,
      dependent: :restrict_with_error

    accepts_nested_attributes_for :mentions, allow_destroy: true
  end
end
