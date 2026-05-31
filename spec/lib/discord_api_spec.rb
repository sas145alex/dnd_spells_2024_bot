require "webmock_helper"

RSpec.describe DiscordAPI do
  it "is a module" do
    expect(described_class).to be_a(Module)
  end

  it "namespaces the client" do
    expect(described_class::Client).to be < Object
  end

  it "namespaces a dedicated API error" do
    expect(described_class::APIError).to be < StandardError
  end

  describe "posting a message through the namespaced client" do
    subject(:send_message) { described_class::Client.new(webhook: webhook).send_message(message) }

    let(:webhook) { "https://discordapp.com/api/webhooks/102030/qwerty" }
    let(:message) { "hello" }

    context "when the webhook accepts the request" do
      let!(:request) { stub_request(:post, webhook).to_return(status: 200, body: "") }

      it "performs the post request" do
        send_message

        expect(request).to have_been_made.once
      end
    end

    context "when the webhook returns an error" do
      before do
        stub_request(:post, webhook).to_return(status: 500, body: "boom")
      end

      it "raises a namespaced APIError" do
        expect { send_message }.to raise_error(described_class::APIError)
      end
    end
  end
end
