class SpellsCharacterKlass < ApplicationRecord
  belongs_to :spell
  belongs_to :character_klass
end
