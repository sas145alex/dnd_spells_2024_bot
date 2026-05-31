require "rails_helper"

RSpec.describe BotRequestJob do
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
