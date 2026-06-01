require "rails_helper"

# Drives the controller's class-level `dispatch` with a ClientStub bot (like spec/requests/telegram_webhook_spec.rb)
# and inspects the recorded requests. Exercises BaseTelegramController dispatch + TelegramController actions.
RSpec.describe TelegramController do
  subject(:dispatch) { described_class.dispatch(bot, update) }

  let(:bot) { Telegram::Bot::ClientStub.new(token: "token", username: "bot_name") }
  let(:external_id) { rand(1_000_000..9_000_000) }
  let(:update) do
    {"message" => {"text" => text, "chat" => {"id" => external_id}, "from" => {"id" => external_id}}}
  end
  let(:text) { "/start" }

  before do
    allow(Telegram::UserMetricsJob).to receive(:perform_later)
    allow(Telegram::ChatMetricsJob).to receive(:perform_later)
  end

  describe "the /start command" do
    let(:text) { "/start" }

    it "replies with the start message" do
      dispatch

      expect(bot.requests[:sendMessage].last).to include(text: include("about command"))
    end

    it "tracks user activity" do
      dispatch

      expect(Telegram::UserMetricsJob).to have_received(:perform_later)
    end
  end

  describe "the /about command" do
    let(:text) { "/about" }

    it "replies with the about message" do
      dispatch

      expect(bot.requests[:sendMessage].last).to include(text: include("about command"))
    end
  end

  describe "the /feedback command without a message" do
    let(:text) { "/feedback" }

    it "replies with the feedback prompt" do
      dispatch

      expect(bot.requests[:sendMessage].last).to include(text: include("feedback command"))
    end
  end

  describe "a non-command text message" do
    let(:text) { "zzz_nonexistent_query_zzz" }

    # GlobalSearch always renders the search filters button; the chat fallback message does not.
    it "performs a global search" do
      dispatch

      expect(bot.requests[:sendMessage].last[:reply_markup]).to eq(
        inline_keyboard: [[{text: "Фильтры 📃", callback_data: "search_filters:"}]]
      )
    end
  end

  describe "the /roll command with a formula" do
    let(:text) { "/roll 2d20" }

    it "replies with the roll result" do
      dispatch

      expect(bot.requests[:sendMessage].last).to include(text: include("Результат"))
    end

    it "offers the another-roll button" do
      dispatch

      expect(bot.requests[:sendMessage].last[:reply_markup]).to eq(
        inline_keyboard: [[{text: "Другой бросок", callback_data: "roll:"}]]
      )
    end
  end

  describe "a go_back callback query with empty history" do
    let(:update) do
      {
        "callback_query" => {
          "id" => "1",
          "data" => "go_back:go_back",
          "from" => {"id" => external_id},
          "message" => {"chat" => {"id" => external_id}, "message_id" => 5}
        }
      }
    end

    it "tells the user the session expired" do
      dispatch

      expect(bot.requests[:sendMessage].last).to include(text: include("твоя сессия истекла"))
    end

    it "is excluded from user activity tracking" do
      dispatch

      expect(Telegram::UserMetricsJob).not_to have_received(:perform_later)
    end
  end

  describe "a go_back callback query replaying a remembered /about state" do
    let(:update) do
      {
        "callback_query" => {
          "id" => "1",
          "data" => "go_back:go_back",
          "from" => {"id" => external_id},
          "message" => {"chat" => {"id" => external_id}, "message_id" => 5}
        }
      }
    end

    before do
      TelegramController.session_store.write(
        "#{bot.username}:#{external_id}",
        {history_stack: [
          {action: "about!", input_value: "/about"},
          {action: "sections_callback_query", input_value: "/sections"}
        ]}
      )
    end

    # Regression for DND-HANDBOOK-3N: replay used to call about!("/about") on a
    # zero-arity action, raising ArgumentError and 500ing the webhook.
    it "replays /about without raising and sends the about message" do
      expect { dispatch }.not_to raise_error
      expect(bot.requests[:sendMessage].last).to include(text: include("about command"))
    end
  end
end
