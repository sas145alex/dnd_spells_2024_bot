require "rails_helper"

# Verifies the Sentry user/tags enrichment in BaseTelegramController#set_sentry_context.
# Drives dispatch with a ClientStub (like spec/requests/telegram_controller_spec.rb) and spies
# on Sentry to assert what context is attached, without needing a live DSN.
RSpec.describe TelegramController do
  subject(:dispatch) { described_class.dispatch(bot, update) }

  let(:bot) { Telegram::Bot::ClientStub.new(token: "token", username: "bot_name") }
  let(:external_id) { rand(1_000_000..9_000_000) }

  before do
    allow(Telegram::UserMetricsJob).to receive(:perform_later)
    allow(Telegram::ChatMetricsJob).to receive(:perform_later)
    allow(Sentry).to receive(:set_user)
    allow(Sentry).to receive(:set_tags)
  end

  describe "a text command" do
    let(:update) do
      {"message" => {"text" => "/start", "chat" => {"id" => external_id, "type" => "private"}, "from" => {"id" => external_id, "username" => "gandalf"}}}
    end

    it "sets the Sentry user from the payload" do
      dispatch

      expect(Sentry).to have_received(:set_user).with(id: external_id, username: "gandalf")
    end

    it "sets searchable tags for the chat type and action" do
      dispatch

      expect(Sentry).to have_received(:set_tags).with(
        hash_including("telegram.chat_type": "private", "telegram.action": "start!")
      )
    end
  end

  describe "a callback query" do
    let(:update) do
      {
        "callback_query" => {
          "id" => "1",
          "data" => "go_back:go_back",
          "from" => {"id" => external_id},
          "message" => {"chat" => {"id" => external_id, "type" => "supergroup"}, "message_id" => 5}
        }
      }
    end

    it "captures the callback prefix as a tag" do
      dispatch

      expect(Sentry).to have_received(:set_tags).with(
        hash_including("telegram.callback_prefix": "go_back", "telegram.chat_type": "supergroup")
      )
    end
  end
end
