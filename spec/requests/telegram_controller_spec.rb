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

  describe "a go_back callback query replaying a remembered my_chat_member state" do
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
          {action: "my_chat_member", input_value: ""},
          {action: "sections_callback_query", input_value: "/sections"}
        ]}
      )
    end

    # Regression for DND-HANDBOOK-3H: replaying a remembered my_chat_member ran
    # MemberChangeProcessor against the go_back callback payload (no new_chat_member),
    # raising NoMethodError ("undefined method 'dig' for nil") and 500ing the webhook.
    # New my_chat_member updates are no longer recorded, but legacy persisted stacks
    # must still replay harmlessly.
    it "replays without raising" do
      expect { dispatch }.not_to raise_error
    end
  end

  # Each of these callback actions strips the prefix from the callback data, calls its
  # BotCommands operation with a blank argument (the top-level category screen), and renders
  # via `edit_message :text`, which the ClientStub records under :editMessageText.
  describe "the callback query actions that edit the message" do
    %w[
      feat class subclass abilities invocations psionic_powers plans
      arcane_shots metamagics maneuvers origin glossary tool equipment species
    ].each do |prefix|
      context "for the #{prefix} callback" do
        let(:update) do
          {
            "callback_query" => {
              "id" => "1",
              "data" => "#{prefix}:",
              "from" => {"id" => external_id},
              "message" => {"chat" => {"id" => external_id}, "message_id" => 5}
            }
          }
        end

        it "edits the message without raising" do
          expect { dispatch }.not_to raise_error
          expect(bot.requests[:editMessageText]).to be_present
        end
      end
    end
  end

  describe "the all_spells callback query" do
    let(:update) do
      {
        "callback_query" => {
          "id" => "1",
          "data" => "all_spells:",
          "from" => {"id" => external_id},
          "message" => {"chat" => {"id" => external_id}, "message_id" => 5}
        }
      }
    end

    it "responds without raising" do
      expect { dispatch }.not_to raise_error
    end
  end

  describe "the search_filters callback query" do
    let(:update) do
      {
        "callback_query" => {
          "id" => "1",
          "data" => "search_filters:",
          "from" => {"id" => external_id},
          "message" => {"chat" => {"id" => external_id}, "message_id" => 5}
        }
      }
    end

    it "edits the message with the filter screen" do
      dispatch

      expect(bot.requests[:editMessageText].last).to include(
        text: include("Разделы справочника")
      )
    end
  end

  describe "the pick_mention callback query" do
    let(:source) { create(:spell, published_at: Time.current) }
    let(:target) { create(:spell, published_at: Time.current) }
    let!(:mention) { create(:mention, mentionable: source, another_mentionable: target) }
    let(:update) do
      {
        "callback_query" => {
          "id" => "1",
          "data" => "pick_mention:#{mention.id}",
          "from" => {"id" => external_id},
          "message" => {"chat" => {"id" => external_id}, "message_id" => 5}
        }
      }
    end

    it "sends the mentioned record's description" do
      dispatch

      expect(bot.requests[:sendMessage].last).to include(
        text: target.decorate.description_for_telegram
      )
    end
  end

  describe "current_user resolution" do
    let(:text) { "zzz_nonexistent_query_zzz" }

    it "creates a TelegramUser the first time a user is seen" do
      expect { dispatch }.to change(TelegramUser, :count).by(1)
      expect(TelegramUser.last).to have_attributes(external_id: external_id)
    end

    it "reuses the existing TelegramUser on subsequent updates" do
      dispatch

      expect { described_class.dispatch(bot, update) }.not_to change(TelegramUser, :count)
    end
  end

  describe "remembering history and replaying it" do
    # Drive a remembered action (feat top-level screen), then a go_back which replays it.
    let(:feat_update) do
      {
        "callback_query" => {
          "id" => "1",
          "data" => "origin:",
          "from" => {"id" => external_id},
          "message" => {"chat" => {"id" => external_id}, "message_id" => 5}
        }
      }
    end
    let(:go_back_update) do
      {
        "callback_query" => {
          "id" => "2",
          "data" => "go_back:go_back",
          "from" => {"id" => external_id},
          "message" => {"chat" => {"id" => external_id}, "message_id" => 6}
        }
      }
    end

    it "records the action and replays it on go_back" do
      described_class.dispatch(bot, feat_update)
      expect { described_class.dispatch(bot, go_back_update) }.not_to raise_error
    end
  end

  describe "a pinned_message update" do
    let(:update) do
      {"message" => {"pinned_message" => {"message_id" => 1}, "chat" => {"id" => external_id}, "from" => {"id" => external_id}}}
    end

    it "is ignored without sending anything" do
      dispatch

      expect(bot.requests[:sendMessage]).to be_blank
    end
  end

  describe "a poll_option_added service message" do
    # Telegram delivers poll service messages to bots in groups regardless of privacy mode.
    # The message carries no `text`, so the whitelist must ignore it entirely.
    let(:chat_id) { external_id + 1 }
    let(:update) do
      {
        "message" => {
          "message_id" => 91,
          "from" => {"id" => external_id},
          "chat" => {"id" => chat_id, "type" => "supergroup"},
          "poll_option_added" => {"option_persistent_id" => "2", "option_text" => "option3"}
        }
      }
    end

    it "is ignored without sending anything" do
      dispatch

      expect(bot.requests[:sendMessage]).to be_blank
    end

    it "does not track user or chat activity" do
      dispatch

      expect(Telegram::UserMetricsJob).not_to have_received(:perform_later)
      expect(Telegram::ChatMetricsJob).not_to have_received(:perform_later)
    end
  end

  describe "a message in a group chat" do
    # In a chat the from id differs from the chat id, so message_from_chat? is true.
    let(:chat_id) { external_id + 1 }
    let(:update) do
      {"message" => {"text" => "hi", "chat" => {"id" => chat_id, "type" => "group"}, "from" => {"id" => external_id}}}
    end

    context "when the bot is not an admin" do
      before { allow_any_instance_of(described_class).to receive(:bot_has_admin_right_in_chat?).and_return(false) }

      it "stays silent on unrecognised text in a group chat" do
        dispatch

        expect(bot.requests[:sendMessage]).to be_blank
      end
    end

    context "when the bot has admin rights" do
      before do
        allow_any_instance_of(described_class).to receive(:bot_has_admin_right_in_chat?).and_return(true)
        allow(TelegramChat::LeaveChat).to receive(:call)
        allow(TelegramChat::MarkAsRemoved).to receive(:call)
      end

      it "leaves the chat and marks it removed" do
        dispatch

        expect(TelegramChat::LeaveChat).to have_received(:call).with(bot: bot, chat_id: chat_id)
        expect(TelegramChat::MarkAsRemoved).to have_received(:call).with(bot: bot, chat_id: chat_id)
      end
    end
  end

  describe "a my_chat_member update" do
    let(:update) do
      {
        "my_chat_member" => {
          "chat" => {"id" => external_id, "type" => "private"},
          "from" => {"id" => external_id},
          "old_chat_member" => {"status" => "left"},
          "new_chat_member" => {"status" => "member"}
        }
      }
    end

    before { allow(TelegramChat::MemberChangeProcessor).to receive(:call) }

    it "routes to the member change processor" do
      dispatch

      expect(TelegramChat::MemberChangeProcessor).to have_received(:call).with(
        hash_including(chat_id: external_id)
      )
    end
  end
end
