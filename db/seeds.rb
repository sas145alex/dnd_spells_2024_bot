BotCommand.find_or_create_by!(title: BotCommand::ABOUT_ID) do |command|
  command.description = "about"
end

AdminUser.find_or_create_by!(id: AdminUser::SYSTEM_USER_ID) do |admin|
  admin.email = "system@system.io"
  admin.password = SecureRandom.hex(8)
end

if Rails.env.development?
  AdminUser.find_or_create_by!(email: "admin@admin.io") do |admin|
    admin.password = "qwerty"
  end
end
