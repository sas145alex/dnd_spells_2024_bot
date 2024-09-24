pp "Performing - #{__FILE__}"

pp "Before count = #{Creature.count}"

if Rails.env.development? && Creature.count == 0
  Services::ImportCreatures.call
end

pp "After count = #{Creature.count}"
