pp "Performing - #{__FILE__}"

pp "Before count = #{Feat.count}"

if Rails.env.development? && Feat.count == 0
  Services::ImportFeats.call
end

pp "After count = #{Feat.count}"
