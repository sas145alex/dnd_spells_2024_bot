require "rails_helper"

RSpec.describe TelegramUser do
  describe "scopes" do
    let!(:active_user) { create(:telegram_user, bot_removed_at: nil) }
    let!(:removed_user) { create(:telegram_user, bot_removed_at: Time.current) }

    describe ".active" do
      subject { described_class.active }

      it { is_expected.to include(active_user) }
      it { is_expected.not_to include(removed_user) }
    end

    describe ".not_active" do
      subject { described_class.not_active }

      it { is_expected.to include(removed_user) }
      it { is_expected.not_to include(active_user) }
    end
  end

  describe ".autocomplete_search" do
    subject { described_class.autocomplete_search(input) }

    let!(:user) { create(:telegram_user, external_id: 424242, username: "gandalf") }

    context "with a blank input" do
      let(:input) { "" }

      it { is_expected.to be_empty }
    end

    context "matching by external_id" do
      let(:input) { "424242" }

      it { is_expected.to include(user) }
    end

    context "matching by username substring" do
      let(:input) { "gand" }

      it { is_expected.to include(user) }
    end

    context "matching nothing" do
      let(:input) { "nonexistent_zzz" }

      it { is_expected.to be_empty }
    end
  end
end
