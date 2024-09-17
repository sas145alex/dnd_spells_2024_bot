class Mention < ApplicationRecord
  belongs_to :mentionable, polymorphic: true
  belongs_to :another_mentionable, polymorphic: true
end
