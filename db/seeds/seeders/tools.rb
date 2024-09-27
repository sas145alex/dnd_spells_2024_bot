pp "Performing - #{__FILE__}"

pp "Before count = #{Tool.count}"

if Rails.env.development? && Tool.count == 0
  Importers::ImportTools.call
end

pp "After count = #{Tool.count}"
