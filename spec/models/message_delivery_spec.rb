require "rails_helper"

RSpec.describe MessageDelivery do
  describe "associations" do
    subject(:delivery) { create(:message_delivery) }

    it "belongs to a message_distribution" do
      expect(delivery.message_distribution).to be_a(MessageDistribution)
    end

    it "has a polymorphic recipient" do
      expect(delivery.recipient).to be_a(TelegramUser)
    end
  end

  describe "status" do
    subject(:delivery) { create(:message_delivery) }

    it "defaults to pending" do
      expect(delivery).to be_pending
    end
  end

  describe "scopes" do
    subject { described_class.public_send(scope) }

    let!(:sent) { create(:message_delivery, :sent) }
    let!(:failed) { create(:message_delivery, :failed) }
    let!(:pending) { create(:message_delivery) }

    context "with sent" do
      let(:scope) { :sent }

      it { is_expected.to contain_exactly(sent) }
    end

    context "with failed" do
      let(:scope) { :failed }

      it { is_expected.to contain_exactly(failed) }
    end

    context "with pending" do
      let(:scope) { :pending }

      it { is_expected.to contain_exactly(pending) }
    end
  end

  describe "error_reason" do
    subject(:delivery) { create(:message_delivery, :failed, error_reason: "chat_not_found") }

    it "exposes a prefixed predicate" do
      expect(delivery).to be_error_chat_not_found
    end
  end
end
