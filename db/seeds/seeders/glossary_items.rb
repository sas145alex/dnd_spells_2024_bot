pp "Performing - #{__FILE__}"

pp "Before count = #{GlossaryItem.count}"

if Rails.env.development? && GlossaryItem.count == 0
  Services::ImportGlossaryItems.call
end

pp "After count = #{GlossaryItem.count}"
