require "rails_helper"

RSpec.describe TelegramChat::MarkAsRemoved do
  subject(:mark_as_removed) { described_class.call(bot: bot, chat_id: chat_id) }

  let(:bot) { nil }
  let(:chat_id) { -100 }

  around do |example|
    Timecop.freeze(Time.parse("2024-10-30")) do
      example.run
    end
  end

  context "when the chat does not exist yet" do
    it "creates a chat" do
      expect { mark_as_removed }.to change { TelegramChat.count }.by(1)
    end

    it "sets bot_removed_at, bot_added_at and last_seen_at" do
      mark_as_removed

      expect(TelegramChat.find_by(external_id: chat_id)).to have_attributes(
        bot_removed_at: Time.current,
        bot_added_at: Time.current,
        last_seen_at: Time.current
      )
    end
  end

  context "when the chat already exists" do
    let!(:chat) do
      create(:telegram_chat, external_id: chat_id, bot_added_at: 2.years.ago, bot_removed_at: nil)
    end

    it "does not create a new chat" do
      expect { mark_as_removed }.not_to change { TelegramChat.count }
    end

    it "sets bot_removed_at" do
      expect { mark_as_removed }.to change { chat.reload.bot_removed_at }.from(nil).to(Time.current)
    end
  end
end
