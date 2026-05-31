require "rails_helper"

RSpec.describe BotCommands::Start do
  subject(:result) { described_class.call }

  let(:command_record) { BotCommand.start.decorate }

  it "renders the seeded start command description" do
    expect(result).to eq(
      text: command_record.description_for_telegram,
      reply_markup: {},
      parse_mode: "HTML"
    )
  end
end
