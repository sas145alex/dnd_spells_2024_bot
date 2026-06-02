require "rails_helper"

RSpec.describe BotRequestJob do
  describe "#perform" do
    subject(:perform) { described_class.new.perform("default", "sendMessage", {chat_id: 1, text: nil}) }

    let(:client) { instance_double(Telegram::Bot::Client) }

    before do
      allow(client).to receive(:async).and_yield
      allow(client).to receive(:request).and_raise(error)
      allow(described_class.client_class).to receive(:wrap).and_return(client)
    end

    context "when Telegram rejects empty message text" do
      let(:error) { Telegram::Bot::Error.new("Bad Request: message text is empty") }

      it "swallows the error instead of retrying and reporting" do
        expect { perform }.not_to raise_error
      end
    end

    context "when Telegram raises an unexpected error" do
      let(:error) { Telegram::Bot::Error.new("Bad Request: something unexpected") }

      it "re-raises" do
        expect { perform }.to raise_error(Telegram::Bot::Error)
      end
    end
  end

  describe "#mark_receiver_as_not_available" do
    subject(:mark) { described_class.new.mark_receiver_as_not_available(payload) }

    let(:payload) { {"chat_id" => chat_id} }
    let(:chat_id) { 12_345 }

    before do
      allow(TelegramChat::MarkAsRemoved).to receive(:call)
      allow(TelegramUser::MarkAsRemoved).to receive(:call)
    end

    it "marks the chat as removed" do
      mark

      expect(TelegramChat::MarkAsRemoved).to have_received(:call).with(bot: nil, chat_id: chat_id)
    end

    it "marks the user as removed" do
      mark

      expect(TelegramUser::MarkAsRemoved).to have_received(:call).with(bot: nil, chat_id: chat_id)
    end

    context "with symbol keys in the payload" do
      let(:payload) { {chat_id: chat_id} }

      it "still resolves the chat_id" do
        mark

        expect(TelegramChat::MarkAsRemoved).to have_received(:call).with(bot: nil, chat_id: chat_id)
      end
    end

    context "when there is no chat_id" do
      let(:payload) { {} }

      it "does nothing" do
        mark

        expect(TelegramChat::MarkAsRemoved).not_to have_received(:call)
      end
    end

    context "when the payload is nil" do
      let(:payload) { nil }

      it "does nothing" do
        mark

        expect(TelegramChat::MarkAsRemoved).not_to have_received(:call)
      end
    end
  end
end
