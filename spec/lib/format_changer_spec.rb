require "rails_helper"

RSpec.describe FormatChanger do
  describe ".markdown_to_html" do
    subject(:html) { described_class.markdown_to_html(text) }

    let(:text) { "" }

    context "with bold markdown" do
      let(:text) { "**bold**" }

      it { is_expected.to include("<strong>bold</strong>") }
    end

    context "with raw HTML in the input" do
      let(:text) { "<script>alert(1)</script>" }

      it { is_expected.not_to include("<script>") }
    end

    context "with a link" do
      let(:text) { "[d&d](https://example.com)" }

      it { is_expected.to include('rel="nofollow"') }
      it { is_expected.to include('target="_blank"') }
    end
  end

  describe ".markdown_to_telegram_markdown" do
    subject(:telegram_html) { described_class.markdown_to_telegram_markdown(text) }

    let(:text) { "" }

    context "with bold markdown" do
      let(:text) { "**bold**" }

      it { is_expected.to include("<b>bold</b>") }
    end

    context "with plain text" do
      let(:text) { "plain text" }

      it "renders through Renderers::TelegramHTML" do
        allow(Renderers::TelegramHTML).to receive(:new).and_call_original

        telegram_html

        expect(Renderers::TelegramHTML).to have_received(:new)
      end
    end
  end
end
