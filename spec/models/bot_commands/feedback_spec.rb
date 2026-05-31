require "rails_helper"

RSpec.describe BotCommands::Feedback do
  describe ".payload_can_be_accepted?" do
    subject(:accepted?) { described_class.payload_can_be_accepted?(payload) }

    context "when the message is regular text" do
      let(:payload) { {"text" => "люблю этого бота"} }

      it { is_expected.to be(true) }
    end

    context "when the message comes from a caption" do
      let(:payload) { {"caption" => "скриншот бага"} }

      it { is_expected.to be(true) }
    end

    context "when the message is a command" do
      let(:payload) { {"text" => "/start"} }

      it { is_expected.to be(false) }
    end

    context "when there is no message" do
      let(:payload) { {} }

      it { is_expected.to be_falsey }
    end
  end

  describe ".message_from_payload" do
    subject(:message) { described_class.message_from_payload(payload) }

    context "when text is present" do
      let(:payload) { {"text" => "из текста"} }

      it { is_expected.to eq("из текста") }
    end

    context "when only a caption is present" do
      let(:payload) { {"caption" => "из подписи"} }

      it { is_expected.to eq("из подписи") }
    end

    context "when caption takes precedence over text" do
      let(:payload) { {"caption" => "подпись", "text" => "текст"} }

      it { is_expected.to eq("подпись") }
    end
  end

  describe ".external_id_from_payload" do
    subject(:external_id) { described_class.external_id_from_payload(payload) }

    let(:payload) { {"from" => {"id" => 4242}} }

    it { is_expected.to eq(4242) }
  end

  describe ".process" do
    subject(:process) { described_class.process(payload) }

    let(:payload) { {"text" => "отличный бот", "from" => {"id" => 777}} }

    before { allow(Feedback::NotificationJob).to receive(:perform_later) }

    it "creates a Feedback record with the parsed attributes" do
      expect { process }.to change(Feedback, :count).by(1)

      feedback = Feedback.last
      expect(feedback).to have_attributes(
        external_user_id: 777,
        message: "отличный бот",
        payload: payload
      )
    end

    it "enqueues a notification job for the new feedback" do
      allow(Feedback::NotificationJob).to receive(:perform_later)

      process

      expect(Feedback::NotificationJob).to have_received(:perform_later).with(Feedback.last.id)
    end
  end
end
