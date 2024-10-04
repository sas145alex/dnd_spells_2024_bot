RSpec.describe BotCommands::About do
  subject { described_class.call }

  let(:bot_command) { BotCommand.about }

  it "returns text from existing bot command entity" do
    expect(subject).to eq(
      {
        text: bot_command.description,
        reply_markup: {},
        parse_mode: "HTML"
      }
    )
  end
end
