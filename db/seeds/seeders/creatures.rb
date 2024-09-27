pp "Performing - #{__FILE__}"

pp "Before count = #{Creature.count}"

if Rails.env.development? && Creature.count == 0
  Importers::ImportCreatures.call
end

pp "After count = #{Creature.count}"
