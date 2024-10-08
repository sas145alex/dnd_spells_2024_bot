pp "Performing - #{__FILE__}"

pp "Before count = #{Invocation.count}"

if Rails.env.development? && Invocation.count == 0
  Importers::ImportInvocations.call
end

pp "After count = #{Invocation.count}"
