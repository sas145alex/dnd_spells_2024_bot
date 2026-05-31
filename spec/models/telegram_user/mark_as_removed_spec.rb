require "rails_helper"

RSpec.describe TelegramUser::MarkAsRemoved do
  subject(:mark_as_removed) { described_class.call(bot: bot, chat_id: chat_id) }

  let(:bot) { nil }
  let(:chat_id) { 555 }

  around do |example|
    Timecop.freeze(Time.parse("2024-10-30")) do
      example.run
    end
  end

  context "when the user does not exist yet" do
    it "creates a user" do
      expect { mark_as_removed }.to change { TelegramUser.count }.by(1)
    end

    it "sets bot_removed_at and last_seen_at" do
      mark_as_removed

      expect(TelegramUser.find_by(external_id: chat_id)).to have_attributes(
        bot_removed_at: Time.current,
        last_seen_at: Time.current
      )
    end
  end

  context "when the user already exists" do
    let!(:user) { create(:telegram_user, external_id: chat_id, bot_removed_at: nil) }

    it "does not create a new user" do
      expect { mark_as_removed }.not_to change { TelegramUser.count }
    end

    it "sets bot_removed_at" do
      expect { mark_as_removed }.to change { user.reload.bot_removed_at }.from(nil).to(Time.current)
    end
  end
end
