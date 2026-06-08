require "rails_helper"

RSpec.describe MessageDistribution::DeliveryJob do
  subject(:run) { described_class.perform_now(distribution) }

  let(:distribution) { create(:message_distribution, status: "queued") }
  let!(:delivery1) { create(:message_delivery, message_distribution: distribution) }
  let!(:delivery2) { create(:message_delivery, message_distribution: distribution) }

  before { allow(Telegram.bot).to receive(:send_message) }

  it "serializes broadcasts with a global concurrency limit of 1" do
    expect(described_class.concurrency_limit).to eq(1)
    expect(described_class.new(distribution).concurrency_key).to include("telegram_broadcast")
  end

  it "delivers all pending recipients and completes the distribution" do
    run

    expect(distribution.reload).to be_completed
    expect(distribution.deliveries).to all(be_sent)
    expect(distribution.delivered_count).to eq(2)
    expect(distribution.finished_at).to be_present
  end

  it "stamps started_at" do
    run

    expect(distribution.reload.started_at).to be_present
  end

  context "when one recipient blocked the bot" do
    before do
      allow(Telegram.bot).to receive(:send_message)
        .with(hash_including(chat_id: delivery1.external_id))
        .and_raise(Telegram::Bot::Forbidden.new("bot was blocked by the user"))
    end

    it "records the failure and still completes" do
      run

      expect(distribution.reload).to be_completed
      expect(distribution.delivered_count).to eq(1)
      expect(distribution.failed_count).to eq(1)
    end
  end

  context "when the distribution is already completed" do
    let(:distribution) { create(:message_distribution, status: "completed") }

    it "does nothing" do
      run

      expect(Telegram.bot).not_to have_received(:send_message)
    end
  end
end
