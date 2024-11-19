pp "Performing - #{__FILE__}"

pp "Before count = #{Metamagic.count}"

if Rails.env.development? && Metamagic.count == 0
  Importers::ImportMetamagics.call
end

pp "After count = #{Metamagic.count}"
