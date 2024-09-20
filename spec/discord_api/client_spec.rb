require "webmock_helper"

RSpec.describe DiscordAPI::Client do
  around do |example|
    Timecop.freeze(Time.parse("2024-10-30")) do
      example.run
    end
  end

  describe ".new" do
    subject(:method) { described_class.new(webhook: "webhook") }

    it "returns an instance" do
      expect(method).to be_a(described_class)
    end
  end

  describe "#send_message" do
    subject(:send_message) { instance.send_message(message, username: username, embeds: embeds) }
    let(:instance) { described_class.new(webhook: webhook) }

    let(:message) { "message" }
    let(:username) { "username" }
    let(:embeds) { [embed] }
    let(:embed) do
      {
        title: "title",
        description: "description",
        timestamp: Time.current.iso8601,
        author: {name: "author"}
      }
    end

    let(:http_library) { HTTParty }

    before do
      allow(http_library).to receive(:post).and_call_original
    end

    context "when webhook is present" do
      let(:webhook) { "https://discordapp.com/api/webhooks/102030/qwerty" }

      let!(:send_message_request) do
        stub_request(:post, webhook).to_return(status: 200, body: "", headers: {})
      end

      it "makes post request" do
        send_message

        expect(send_message_request).to have_been_made.once
        expect(http_library).to have_received(:post)
      end
    end

    context "when webhook is not present" do
      let(:webhook) { nil }

      it "does not make any request" do
        expect(http_library).not_to have_received(:post)
      end
    end
  end
end
