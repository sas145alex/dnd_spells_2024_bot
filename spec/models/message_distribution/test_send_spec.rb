require "rails_helper"

RSpec.describe MessageDistribution::TestSend do
  subject(:test_send) { described_class.call(distribution: distribution, chat_ids: ids) }

  let(:distribution) { create(:message_distribution) }
  let(:ids) { ["111", "-100222"] }

  before { allow(Telegram.bot).to receive(:send_message) }

  it "sends to each id (users or chats) without persisting deliveries" do
    expect { test_send }.not_to change(MessageDelivery, :count)
    expect(Telegram.bot).to have_received(:send_message).with(hash_including(chat_id: 111)).once
    expect(Telegram.bot).to have_received(:send_message).with(hash_including(chat_id: -100222)).once
  end

  it "does not change the distribution status" do
    expect { test_send }.not_to change { distribution.reload.status }
  end

  context "with no ids" do
    let(:ids) { [""] }

    it { is_expected.to be(false) }
  end
end
