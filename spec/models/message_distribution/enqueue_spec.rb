require "rails_helper"

RSpec.describe MessageDistribution::Enqueue do
  subject(:enqueue) { described_class.new(distribution: distribution) }

  let(:distribution) do
    create(:message_distribution,
      send_to_users: true,
      send_to_chats: false,
      only_active: true,
      active_since: nil,
      min_command_count: nil)
  end

  let!(:user1) { create(:telegram_user) }
  let!(:user2) { create(:telegram_user) }

  before { allow(MessageDistribution::DeliveryJob).to receive(:perform_later) }

  describe "#call" do
    it "materializes a pending delivery per recipient" do
      expect { enqueue.call }.to change(MessageDelivery, :count).by(2)
      expect(distribution.deliveries.pluck(:external_id)).to match_array([user1.external_id, user2.external_id])
      expect(distribution.deliveries).to all(be_pending)
    end

    it "marks the distribution queued with a recipients_count" do
      enqueue.call

      expect(distribution.reload).to be_queued
      expect(distribution.recipients_count).to eq(2)
    end

    it "enqueues the delivery job" do
      enqueue.call

      expect(MessageDistribution::DeliveryJob).to have_received(:perform_later).with(distribution)
    end

    it { expect(enqueue.call).to be(true) }

    context "when the audience is empty" do
      let(:distribution) { create(:message_distribution, send_to_users: false, send_to_chats: false) }

      it "returns false and does not enqueue" do
        expect(enqueue.call).to be(false)
        expect(MessageDistribution::DeliveryJob).not_to have_received(:perform_later)
      end
    end

    context "when the distribution was already sent" do
      let(:distribution) { create(:message_distribution, status: "completed") }

      it "returns false with an error" do
        expect(enqueue.call).to be(false)
        expect(enqueue.errors.full_messages).to include(a_string_matching(/уже была отправлена/))
      end
    end
  end
end
