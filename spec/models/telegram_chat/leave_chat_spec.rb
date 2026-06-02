require "rails_helper"

RSpec.describe TelegramChat::LeaveChat do
  subject(:leave_chat) { described_class.call(bot: bot, chat_id: chat_id) }

  let(:bot) { Telegram::Bot::ClientStub.new(token: "token", username: "bot_name") }
  let(:chat_id) { -100 }

  context "when the bot can leave the chat" do
    it "warns the chat" do
      leave_chat

      expect(bot.requests[:sendMessage]).to include(
        hash_including(chat_id: chat_id, text: "Не назначай меня администратором")
      )
    end

    it "leaves the chat" do
      leave_chat

      expect(bot.requests[:leaveChat]).to include(hash_including(chat_id: chat_id))
    end
  end

  context "when sending the message is forbidden" do
    before do
      allow(bot).to receive(:send_message).and_raise(Telegram::Bot::Forbidden)
    end

    it "swallows the error and returns nil" do
      expect(leave_chat).to be_nil
    end
  end

  # Regression for DND-HANDBOOK-33: when the bot's admin rights are revoked between the
  # my_chat_member notification and the send, Telegram raises a plain Telegram::Bot::Error
  # ("need administrator rights in the channel chat") — not a Forbidden — which used to escape
  # the rescue and 500 the synchronous webhook.
  context "when the send raises a non-Forbidden Telegram error" do
    before do
      allow(Rails.logger).to receive(:info)
      allow(bot).to receive(:send_message).and_raise(
        Telegram::Bot::Error.new("Bad Request: need administrator rights in the channel chat")
      )
    end

    it "swallows the error and returns nil" do
      expect(leave_chat).to be_nil
    end

    it "logs the skipped send" do
      leave_chat

      expect(Rails.logger).to have_received(:info).with(/TelegramChat::LeaveChat skipped/)
    end
  end
end
