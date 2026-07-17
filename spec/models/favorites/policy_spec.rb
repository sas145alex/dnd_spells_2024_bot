require "rails_helper"

RSpec.describe Favorites::Policy do
  subject(:policy) { described_class.new(user) }

  describe "#can_use?" do
    context "when the user is an admin" do
      let(:user) { build(:telegram_user, :admin) }

      it { expect(policy.can_use?).to be(true) }
    end

    context "when the user is not an admin" do
      let(:user) { build(:telegram_user) }

      it { expect(policy.can_use?).to be(false) }
    end

    context "when there is no user" do
      let(:user) { nil }

      it { expect(policy.can_use?).to be(false) }
    end
  end

  describe ".can_use?" do
    subject { described_class.can_use?(user) }

    context "when the user is an admin" do
      let(:user) { build(:telegram_user, :admin) }

      it { is_expected.to be(true) }
    end

    context "when the user is not an admin" do
      let(:user) { build(:telegram_user) }

      it { is_expected.to be(false) }
    end
  end
end
