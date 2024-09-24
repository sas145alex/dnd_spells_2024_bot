pp "Performing - #{__FILE__}"

pp "Before count = #{AdminUser.count}"

if Rails.env.development?
  AdminUser.find_or_create_by!(id: AdminUser::SYSTEM_USER_ID) do |admin|
    admin.email = "system@system.io"
    admin.password = SecureRandom.hex(8)
  end
end

pp "After count = #{AdminUser.count}"
