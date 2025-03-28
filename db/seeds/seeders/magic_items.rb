pp "Performing - #{__FILE__}"

pp "Before count = #{MagicItem.count}"

if Rails.env.development? && MagicItem.count == 0
  Importers::ImportMagicItems.call
end

pp "After count = #{MagicItem.count}"
