RSpec.describe Feedback do
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

  describe ".create" do
    subject(:create_message) do
      described_class.create(text: text, author: author, timestamp: timestamp)
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
      create_message

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
end
