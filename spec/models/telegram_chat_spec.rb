require "rails_helper"

RSpec.describe TelegramChat do
  describe "scopes" do
    let!(:active_chat) { create(:telegram_chat, bot_removed_at: nil) }
    let!(:removed_chat) { create(:telegram_chat, bot_removed_at: Time.current) }

    describe ".active" do
      subject { described_class.active }

      it { is_expected.to include(active_chat) }
      it { is_expected.not_to include(removed_chat) }
    end

    describe ".not_active" do
      subject { described_class.not_active }

      it { is_expected.to include(removed_chat) }
      it { is_expected.not_to include(active_chat) }
    end
  end
end
