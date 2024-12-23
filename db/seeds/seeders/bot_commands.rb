pp "Performing - #{__FILE__}"

pp "Before count = #{BotCommand.count}"

BotCommand.find_or_create_by!(title: BotCommand::START_ID) do |command|
  command.description = "about command"
end

BotCommand.find_or_create_by!(title: BotCommand::ABOUT_ID) do |command|
  command.description = "about command"
end

BotCommand.find_or_create_by!(title: BotCommand::TOOL_ID) do |command|
  command.description = "tool command"
end

BotCommand.find_or_create_by!(title: BotCommand::CRAFTING_ID) do |command|
  command.description = "tool command - crafting subcommand"
end

BotCommand.find_or_create_by!(title: BotCommand::ORIGIN_ID) do |command|
  command.description = "origin command"
end

BotCommand.find_or_create_by!(title: BotCommand::FEEDBACK_ID) do |command|
  command.description = "feedback command"
end

EquipmentItem.item_types.keys.each do |type|
  BotCommand.find_or_create_by!(title: "#{type}_section_description") do |command|
    command.description = "description for section #{type}"
  end
end

pp "After count = #{BotCommand.count}"
