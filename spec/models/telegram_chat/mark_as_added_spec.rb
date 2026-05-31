require "rails_helper"

RSpec.describe TelegramChat::MarkAsAdded do
  subject(:mark_as_added) { described_class.call(bot: bot, chat_id: chat_id) }

  let(:bot) { nil }
  let(:chat_id) { -100 }

  around do |example|
    Timecop.freeze(Time.parse("2024-10-30")) do
      example.run
    end
  end

  context "when the chat does not exist yet" do
    it "creates a chat" do
      expect { mark_as_added }.to change { TelegramChat.count }.by(1)
    end

    it "sets bot_added_at and last_seen_at and leaves bot_removed_at nil" do
      mark_as_added

      expect(TelegramChat.find_by(external_id: chat_id)).to have_attributes(
        bot_added_at: Time.current,
        last_seen_at: Time.current,
        bot_removed_at: nil
      )
    end
  end

  context "when the chat already exists and was previously removed" do
    let!(:chat) do
      create(:telegram_chat, external_id: chat_id, bot_removed_at: 1.year.ago, bot_added_at: 2.years.ago)
    end

    it "does not create a new chat" do
      expect { mark_as_added }.not_to change { TelegramChat.count }
    end

    it "updates bot_added_at and clears bot_removed_at" do
      mark_as_added

      expect(chat.reload).to have_attributes(
        bot_added_at: Time.current,
        bot_removed_at: nil
      )
    end
  end
end
