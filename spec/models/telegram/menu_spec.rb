require "rails_helper"

RSpec.describe Telegram::Menu do
  describe "COMMANDS" do
    subject(:commands) { described_class::COMMANDS }

    it "advertises the favorites list under the same label as the section button" do
      expect(commands).to include(command: "favorites", description: BotCommands::FavoritesList::HEADER)
    end

    it "only lists commands the bot actually implements" do
      missing = commands.reject { |command| TelegramController.method_defined?(:"#{command[:command]}!") }

      expect(missing).to be_empty
    end

    it "keeps every command name within Telegram's format" do
      expect(commands.map { |command| command[:command] }).to all(match(/\A[a-z0-9_]{1,32}\z/))
    end

    it "keeps every description within Telegram's length limit" do
      expect(commands.map { |command| command[:description].size }).to all(be_between(1, 256))
    end
  end

  describe ".set!" do
    subject(:set!) { described_class.set! }

    before { allow(Telegram.bot).to receive(:set_my_commands) }

    it "pushes the whole list to Telegram" do
      set!

      expect(Telegram.bot).to have_received(:set_my_commands).with(commands: described_class::COMMANDS)
    end
  end
end
