namespace :telegram do
  namespace :bot do
    desc "Push the slash-menu command list (setMyCommands) to Telegram"
    task set_commands: :environment do
      # Naming the target first: .env.test carries a placeholder BOT_TOKEN, so a run from the test
      # env answers a bare 404 that says nothing about which bot was addressed.
      puts "Pushing #{Telegram::Menu::COMMANDS.size} commands to @#{Telegram.bot.username} (#{Rails.env})"
      pp Telegram::Menu.set!
    end
  end
end
