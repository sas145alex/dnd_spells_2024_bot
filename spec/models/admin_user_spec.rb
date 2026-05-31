require "rails_helper"

RSpec.describe AdminUser do
  describe "validations" do
    subject(:admin) { build(:admin_user, email: email) }

    context "with a valid email" do
      let(:email) { "admin@example.com" }

      it { is_expected.to be_valid }
    end

    context "without an email" do
      let(:email) { nil }

      it { is_expected.not_to be_valid }
    end
  end

  describe ".system_user" do
    subject(:system_user) { described_class.system_user }

    context "when the system user exists" do
      let!(:existing) do
        create(:admin_user).tap do |user|
          user.update_column(:id, described_class::SYSTEM_USER_ID)
        end
      end

      before { described_class.instance_variable_set(:@system_user, nil) }

      it { is_expected.to eq(described_class.find(described_class::SYSTEM_USER_ID)) }
    end
  end
end
