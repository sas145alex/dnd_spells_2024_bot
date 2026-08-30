require "rails_helper"

RSpec.describe Favorites::Policy do
  subject(:policy) { described_class.new(user) }

  let(:user) { create(:telegram_user) }

  describe "#can_use?" do
    subject { policy.can_use? }

    context "when the user is an admin" do
      let(:user) { create(:telegram_user, :admin) }

      it { is_expected.to be(true) }
    end

    context "when the user is not an admin" do
      it { is_expected.to be(true) }
    end

    context "when there is no user" do
      let(:user) { nil }

      it { is_expected.to be(false) }
    end
  end

  describe "#limit" do
    subject { policy.limit }

    context "when the user is an admin" do
      let(:user) { create(:telegram_user, :admin) }

      it { is_expected.to be_nil }
    end

    context "when the user is not an admin" do
      it { is_expected.to eq(described_class::FREE_LIMIT) }
    end
  end

  describe "#can_add?" do
    subject { policy.can_add? }

    context "when the user is below the limit" do
      before { create_list(:favorite, described_class::FREE_LIMIT - 1, telegram_user: user) }

      it { is_expected.to be(true) }
    end

    context "when the user is at the limit" do
      before { create_list(:favorite, described_class::FREE_LIMIT, telegram_user: user) }

      it { is_expected.to be(false) }
    end

    context "when an admin is over the limit" do
      let(:user) { create(:telegram_user, :admin) }

      before { create_list(:favorite, described_class::FREE_LIMIT + 1, telegram_user: user) }

      it { is_expected.to be(true) }
    end

    context "when there is no user" do
      let(:user) { nil }

      it { is_expected.to be(false) }
    end
  end

  describe ".can_use?" do
    subject { described_class.can_use?(user) }

    context "when the user is not an admin" do
      it { is_expected.to be(true) }
    end

    context "when there is no user" do
      let(:user) { nil }

      it { is_expected.to be(false) }
    end
  end
end
