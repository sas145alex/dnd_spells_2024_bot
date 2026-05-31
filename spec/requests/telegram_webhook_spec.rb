require "rails_helper"

# Exemplar controller spec for the Telegram webhook. Instead of POSTing over HTTP (the route binds a
# real bot at boot), we drive the controller's class-level `dispatch` with our own ClientStub bot and
# inspect the recorded requests. This exercises BaseTelegramController dispatch + TelegramController.
RSpec.describe TelegramController do
  describe ".dispatch" do
    subject(:dispatch) { described_class.dispatch(bot, update) }

    let(:bot) { Telegram::Bot::ClientStub.new(token: "token", username: "bot_name") }
    let(:text) { "/start" }
    let(:update) do
      {"message" => {"text" => text, "chat" => {"id" => 456}, "from" => {"id" => 123}}}
    end

    before do
      allow(Telegram::UserMetricsJob).to receive(:perform_later)
      allow(Telegram::ChatMetricsJob).to receive(:perform_later)
    end

    context "with the /start command" do
      let(:text) { "/start" }

      # BotCommands::Start renders the seeded BotCommand.start description ("about command").
      it "replies with the start message" do
        dispatch

        expect(bot.requests[:sendMessage].last).to include(text: include("about command"))
      end
    end
  end
end
