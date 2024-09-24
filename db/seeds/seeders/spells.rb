pp "Performing - #{__FILE__}"

pp "Before count = #{Spell.count}"

if Rails.env.development? && Spell.count == 0
  Services::ImportSpells.call
end

pp "After count = #{Spell.count}"
