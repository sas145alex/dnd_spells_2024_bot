pp "Performing - #{__FILE__}"

pp "Before count = #{BotCommand.count}"

BotCommand.find_or_create_by!(title: BotCommand::ABOUT_ID) do |command|
  command.description = "about command"
end

BotCommand.find_or_create_by!(title: BotCommand::TOOL_ID) do |command|
  command.description = "tool command"
end

pp "After count = #{BotCommand.count}"
