pp "Performing - #{__FILE__}"

pp "Before count = #{Bastion.count}"

if Rails.env.development? && Bastion.count == 0
  Importers::ImportBastions.call
end

pp "After count = #{Bastion.count}"
