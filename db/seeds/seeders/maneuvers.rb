pp "Performing - #{__FILE__}"

pp "Before count = #{Maneuver.count}"

if Rails.env.development? && Maneuver.count == 0
  Importers::ImportManeuvers.call
end

pp "After count = #{Maneuver.count}"
