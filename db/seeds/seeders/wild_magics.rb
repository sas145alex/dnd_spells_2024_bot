pp "Performing - #{__FILE__}"

pp "Before count = #{WildMagic.count}"

if Rails.env.development? && WildMagic.count == 0
  Services::ImportWildMagics.call
end

pp "After count = #{WildMagic.count}"