require "rails_helper"

RSpec.describe MessageDistribution::DeliverOne do
  subject(:deliver) { described_class.new(delivery: delivery) }

  let(:distribution) { create(:message_distribution) }
  let(:recipient) { create(:telegram_user) }
  let(:delivery) do
    create(:message_delivery,
      message_distribution: distribution,
      recipient: recipient,
      external_id: recipient.external_id)
  end

  before do
    allow(Telegram.bot).to receive(:send_message)
    allow(TelegramUser::MarkAsRemoved).to receive(:call)
    allow(Sentry).to receive(:capture_exception)
  end

  context "when the send succeeds" do
    it "marks the delivery sent" do
      expect(deliver.call).to be(true)
      expect(delivery.reload).to be_sent
      expect(delivery.sent_at).to be_present
    end

    it "sends the distribution text to the recipient" do
      deliver.call

      expect(Telegram.bot).to have_received(:send_message).with(
        chat_id: recipient.external_id,
        text: instance_of(String),
        parse_mode: "HTML"
      )
    end
  end

  context "when the user blocked the bot" do
    before do
      allow(Telegram.bot).to receive(:send_message)
        .and_raise(Telegram::Bot::Forbidden.new("Forbidden: bot was blocked by the user"))
    end

    it "marks the delivery failed as blocked" do
      expect(deliver.call).to be(false)
      expect(delivery.reload).to be_failed
      expect(delivery).to be_error_blocked
    end

    it "marks the recipient as removed" do
      deliver.call

      expect(TelegramUser::MarkAsRemoved).to have_received(:call).with(bot: nil, chat_id: recipient.external_id)
    end
  end

  context "when the user is deactivated" do
    before do
      allow(Telegram.bot).to receive(:send_message)
        .and_raise(Telegram::Bot::Forbidden.new("Forbidden: user is deactivated"))
    end

    it { expect { deliver.call }.to change { delivery.reload.error_reason }.to("deactivated") }
  end

  context "when the chat is not found" do
    before do
      allow(Telegram.bot).to receive(:send_message)
        .and_raise(Telegram::Bot::NotFound.new("Bad Request: chat not found"))
    end

    it { expect { deliver.call }.to change { delivery.reload.error_reason }.to("chat_not_found") }
  end

  context "with a persistent flood-control error" do
    before do
      allow(Telegram.bot).to receive(:send_message)
        .and_raise(Telegram::Bot::Error.new("Too Many Requests: retry after 30"))
    end

    it { expect { deliver.call }.to change { delivery.reload.error_reason }.to("flood_wait") }
  end

  context "with a transient flood that clears on retry" do
    before do
      call_count = 0
      allow(Telegram.bot).to receive(:send_message) do
        call_count += 1
        raise Telegram::Bot::Error.new("Too Many Requests: retry after 1") if call_count == 1
        nil
      end
    end

    it "retries once and marks the delivery sent" do
      expect(deliver.call).to be(true)
      expect(delivery.reload).to be_sent
      expect(Telegram.bot).to have_received(:send_message).twice
    end
  end

  context "with an unexpected error" do
    before do
      allow(Telegram.bot).to receive(:send_message)
        .and_raise(Telegram::Bot::Error.new("Bad Request: something odd"))
    end

    it "marks it as other and reports to Sentry" do
      expect(deliver.call).to be(false)
      expect(delivery.reload).to be_error_other
      expect(Sentry).to have_received(:capture_exception)
    end
  end
end
