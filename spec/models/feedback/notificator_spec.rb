RSpec.describe Feedback::Notificator do
  describe ".notification_client" do
    subject(:client) { described_class.notification_client }

    it "initializes client of proper notification service" do
      expect(client).to be_a(DiscordAPI::Client)
    end

    it "passes proper webhook to client" do
      aggregate_failures do
        expect(ENV["ADVICE_WEBHOOK"]).not_to be_blank
        expect(client.webhook).to eq(ENV["ADVICE_WEBHOOK"])
      end
    end

    context "when invokes several times" do
      it "uses the same object" do
        first_object_id = described_class.notification_client
        second_object_id = described_class.notification_client

        expect(first_object_id).to eq(second_object_id)
      end
    end
  end

  describe ".notify!" do
    subject(:notify) do
      described_class.notify!(text: text, author: author, timestamp: timestamp)
    end

    let(:text) { "text" }
    let(:author) { "author" }
    let(:timestamp) { Time.current }

    let(:client) { instance_double(DiscordAPI::Client) }

    before do
      allow(described_class).to receive(:notification_client).and_return(client)
      allow(client).to receive(:send_message)
    end

    around do |example|
      Timecop.freeze(Time.parse("2024-10-30")) do
        example.run
      end
    end

    it "sends message with proper attributes" do
      notify

      expect(client).to have_received(:send_message).with(
        embeds: [
          {
            title: "Feedback",
            description: text,
            timestamp: timestamp,
            color: described_class::AQUA_COLOR,
            author: {name: author}
          }
        ]
      )
    end
  end

  describe ".call" do
    subject(:call) { described_class.call(feedback) }

    around do |example|
      Timecop.freeze(Time.parse("2024-10-30")) do
        example.run
      end
    end

    let(:feedback) { build(:feedback, payload: payload) }
    let(:payload) do
      {
        "message_id" => 467,
        "from" => from,
        "chat" => chat,
        "date" => message_time,
        "text" => text
      }
    end
    let(:from) do
      {
        "id" => 123,
        "first_name" => "John",
        "last_name" => "Smith",
        "username" => "johnsmith"
      }
    end
    let(:chat) do
      {
        "id" => 1350564680,
        "first_name" => "FirstName",
        "last_name" => "LastName",
        "username" => "UserName",
        "type" => "private"
      }
    end
    let(:message_time) { Time.now.to_i }
    let(:text) { "text" }

    before do
      allow(described_class).to receive(:notify!)
    end

    it "sends notification" do
      call

      expect(described_class).to have_received(:notify!).with(
        text: text,
        author: "ID: 123 - John - Smith - johnsmith",
        timestamp: Time.at(message_time)
      )
    end
  end
end
