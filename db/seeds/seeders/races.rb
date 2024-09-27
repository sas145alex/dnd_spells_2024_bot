pp "Performing - #{__FILE__}"

pp "Before count = #{Race.count}"

if Rails.env.development? && Race.count == 0
  Importers::ImportRaces.call
end

pp "After count = #{Race.count}"
