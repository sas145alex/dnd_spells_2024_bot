require "rails_helper"

# Drives the controller's class-level `dispatch` with a ClientStub bot (like spec/requests/telegram_controller_spec.rb)
# and verifies the admin-only /error command: admins trigger a raise, non-admins are silently ignored.
RSpec.describe TelegramController do
  subject(:dispatch) { described_class.dispatch(bot, update) }

  let(:bot) { Telegram::Bot::ClientStub.new(token: "token", username: "bot_name") }
  let(:external_id) { rand(1_000_000..9_000_000) }
  let(:text) { "/error" }
  let(:update) do
    {"message" => {"text" => text, "chat" => {"id" => external_id}, "from" => {"id" => external_id}}}
  end

  before do
    allow(Telegram::UserMetricsJob).to receive(:perform_later)
    allow(Telegram::ChatMetricsJob).to receive(:perform_later)
  end

  context "when the sender is an admin" do
    before { create(:telegram_user, :admin, external_id: external_id) }

    context "with custom text" do
      let(:text) { "/error boom" }

      it "raises the test error with the given message" do
        expect { dispatch }.to raise_error(BotCommands::Error::TestError, "boom")
      end
    end

    context "without text" do
      it "raises the test error with the default message" do
        expect { dispatch }.to raise_error(BotCommands::Error::TestError, BotCommands::Error::DEFAULT_MESSAGE)
      end
    end
  end

  context "when the sender is not an admin" do
    it "does not raise" do
      expect { dispatch }.not_to raise_error
    end

    it "sends no message" do
      dispatch

      expect(bot.requests[:sendMessage]).to be_empty
    end
  end
end
