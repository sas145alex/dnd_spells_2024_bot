RSpec.describe MessageDistribution::Send do
  subject { described_class.call(distribution: distribution, options: options) }

  around do |example|
    Timecop.freeze(Time.parse("2024-10-30")) do
      example.run
    end
  end

  let!(:distribution) { create(:message_distribution, content: content) }
  let(:content) { "important text" }
  let(:options) do
    {
      "telegram_user_ids" => [""],
      "active_since" => "2024-08-19 11:01",
      "test_sending" => "1",
      "send_to_users" => "1",
      "send_to_chats" => "1"
    }
  end

  let!(:user1) { create(:telegram_user, external_id: 111) }
  let!(:user2) { create(:telegram_user, external_id: 222) }
  let!(:chat1) { create(:telegram_chat, external_id: 333) }
  let!(:chat2) { create(:telegram_chat, external_id: 444) }

  before do
    allow(Telegram.bot).to receive(:send_message)
  end

  it "sends text to all users and chats" do
    expect(subject).to eq(true)

    expect(Telegram.bot).to have_received(:send_message).with(
      chat_id: user1.external_id,
      parse_mode: "HTML",
      text: instance_of(String)
    )
    expect(Telegram.bot).to have_received(:send_message).with(
      chat_id: user2.external_id,
      parse_mode: "HTML",
      text: instance_of(String)
    )
    expect(Telegram.bot).to have_received(:send_message).with(
      chat_id: chat1.external_id,
      parse_mode: "HTML",
      text: instance_of(String)
    )
    expect(Telegram.bot).to have_received(:send_message).with(
      chat_id: chat2.external_id,
      parse_mode: "HTML",
      text: instance_of(String)
    )
  end

  context "when user ids specified" do
    let(:options) do
      super().tap do |hash|
        hash["telegram_user_ids"] = [user2.external_id.to_s]
      end
    end

    it "sends text to specified user" do
      expect(subject).to eq(true)

      expect(Telegram.bot).not_to have_received(:send_message).with(
        chat_id: user1.external_id,
        parse_mode: "HTML",
        text: instance_of(String)
      )
      expect(Telegram.bot).to have_received(:send_message).with(
        chat_id: user2.external_id,
        parse_mode: "HTML",
        text: instance_of(String)
      )

      expect(Telegram.bot).to have_received(:send_message).with(
        chat_id: chat1.external_id,
        parse_mode: "HTML",
        text: instance_of(String)
      )
      expect(Telegram.bot).to have_received(:send_message).with(
        chat_id: chat2.external_id,
        parse_mode: "HTML",
        text: instance_of(String)
      )
    end
  end

  context "when this is not a test sending" do
    let(:options) do
      super().tap do |hash|
        hash["test_sending"] = "0"
      end
    end

    it "sends text to all users" do
      expect(subject).to eq(true)

      expect(Telegram.bot).to have_received(:send_message).with(
        chat_id: user1.external_id,
        parse_mode: "HTML",
        text: instance_of(String)
      )
      expect(Telegram.bot).to have_received(:send_message).with(
        chat_id: user2.external_id,
        parse_mode: "HTML",
        text: instance_of(String)
      )
      expect(Telegram.bot).to have_received(:send_message).with(
        chat_id: chat1.external_id,
        parse_mode: "HTML",
        text: instance_of(String)
      )
      expect(Telegram.bot).to have_received(:send_message).with(
        chat_id: chat2.external_id,
        parse_mode: "HTML",
        text: instance_of(String)
      )
    end

    it "updates last_sent_at attribute" do
      expect { subject }.to change { distribution.last_sent_at }.from(nil).to(Time.current)
    end
  end
end
