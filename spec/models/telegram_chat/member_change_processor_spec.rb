require "rails_helper"

RSpec.describe TelegramChat::MemberChangeProcessor do
  describe "#call" do
    subject(:process) { described_class.call(bot: bot, payload: payload, chat_id: chat_id) }

    let(:bot) { instance_double(Telegram::Bot::Client, username: "dnd_bot") }
    let(:chat_id) { -100 }
    let(:status) { "member" }
    let(:is_bot) { true }
    let(:username) { "dnd_bot" }
    let(:payload) do
      {
        "new_chat_member" => {
          "user" => {"is_bot" => is_bot, "username" => username},
          "status" => status
        }
      }
    end

    before do
      allow(TelegramChat::MarkAsAdded).to receive(:call)
      allow(TelegramChat::MarkAsRemoved).to receive(:call)
      allow(TelegramChat::LeaveChat).to receive(:call)
    end

    context "when the bot is added (status: member)" do
      let(:status) { "member" }

      it "marks the chat as added" do
        process

        expect(TelegramChat::MarkAsAdded).to have_received(:call).with(bot: bot, chat_id: -100)
      end
    end

    context "when the bot is removed (status: left)" do
      let(:status) { "left" }

      it "marks the chat as removed" do
        process

        expect(TelegramChat::MarkAsRemoved).to have_received(:call).with(bot: bot, chat_id: -100)
      end
    end

    context "when the bot is kicked (status: kicked)" do
      let(:status) { "kicked" }

      it "marks the chat as removed" do
        process

        expect(TelegramChat::MarkAsRemoved).to have_received(:call).with(bot: bot, chat_id: -100)
      end
    end

    context "when the bot is made administrator" do
      let(:status) { "administrator" }

      it "leaves the chat and marks it as removed" do
        process

        expect(TelegramChat::LeaveChat).to have_received(:call).with(bot: bot, chat_id: -100)
        expect(TelegramChat::MarkAsRemoved).to have_received(:call).with(bot: bot, chat_id: -100)
      end
    end

    context "when the bot is restricted" do
      let(:status) { "restricted" }

      it "does nothing" do
        process

        expect(TelegramChat::MarkAsAdded).not_to have_received(:call)
        expect(TelegramChat::MarkAsRemoved).not_to have_received(:call)
      end
    end

    context "when the change concerns another (non-bot) member" do
      let(:is_bot) { false }

      it "does nothing" do
        process

        expect(TelegramChat::MarkAsAdded).not_to have_received(:call)
        expect(TelegramChat::MarkAsRemoved).not_to have_received(:call)
      end
    end

    context "when the change concerns a different bot" do
      let(:username) { "some_other_bot" }

      it "does nothing" do
        process

        expect(TelegramChat::MarkAsAdded).not_to have_received(:call)
        expect(TelegramChat::MarkAsRemoved).not_to have_received(:call)
      end
    end
  end
end
