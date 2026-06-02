require "rails_helper"

RSpec.describe TelegramErrorFingerprint do
  describe ".fingerprint_for" do
    subject(:fingerprint) { described_class.fingerprint_for(exception) }

    context "with a Telegram error" do
      let(:exception) { Telegram::Bot::Error.new("Bad Request: TOPIC_CLOSED") }

      it { is_expected.to eq(["{{ default }}", "Telegram::Bot::Error", "bad request: topic_closed"]) }
    end

    context "with a different Telegram message" do
      let(:exception) { Telegram::Bot::Error.new("Bad Request: message text is empty") }

      it "produces a different fingerprint" do
        other = described_class.fingerprint_for(Telegram::Bot::Error.new("Bad Request: TOPIC_CLOSED"))

        expect(fingerprint).not_to eq(other)
      end
    end

    context "with the same message but different digits" do
      let(:exception) { Telegram::Bot::Error.new("Too Many Requests: retry after 30") }

      it "normalizes to the same fingerprint" do
        other = described_class.fingerprint_for(Telegram::Bot::Error.new("Too Many Requests: retry after 9"))

        expect(fingerprint).to eq(other)
      end
    end

    context "with a Telegram subclass" do
      let(:exception) { Telegram::Bot::Forbidden.new("Forbidden: bot was blocked by the user") }

      it { is_expected.to eq(["{{ default }}", "Telegram::Bot::Forbidden", "forbidden: bot was blocked by the user"]) }
    end

    context "with a non-Telegram error" do
      let(:exception) { StandardError.new("boom") }

      it { is_expected.to be_nil }
    end

    context "with no exception" do
      let(:exception) { nil }

      it { is_expected.to be_nil }
    end
  end

  describe ".call" do
    subject(:returned) { described_class.call(event, hint) }

    let(:event) { Struct.new(:fingerprint).new }

    context "for a Telegram error" do
      let(:hint) { {exception: Telegram::Bot::Error.new("Bad Request: TOPIC_CLOSED")} }

      it "sets the fingerprint on the event" do
        expect(returned.fingerprint).to eq(["{{ default }}", "Telegram::Bot::Error", "bad request: topic_closed"])
      end
    end

    context "for a non-Telegram error" do
      let(:hint) { {exception: StandardError.new("boom")} }

      it "leaves the fingerprint unset and returns the event" do
        expect(returned).to be(event)
        expect(returned.fingerprint).to be_nil
      end
    end
  end
end
