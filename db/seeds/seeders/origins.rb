pp "Performing - #{__FILE__}"

pp "Before count = #{Origin.count}"

if Rails.env.development? && Origin.count == 0
  Importers::ImportOrigins.call
end

pp "After count = #{Origin.count}"
