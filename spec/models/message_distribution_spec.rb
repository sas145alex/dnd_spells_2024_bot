require "rails_helper"

RSpec.describe MessageDistribution do
  it_behaves_like "who_did_itable", :message_distribution

  describe "validations" do
    subject(:record) { build(:message_distribution, title: title, content: content) }

    let(:title) { "Weekly update" }
    let(:content) { "Some content here." }

    it { is_expected.to be_valid }

    context "without a title" do
      let(:title) { nil }

      it { is_expected.not_to be_valid }
    end

    context "with a too-short title" do
      let(:title) { "ab" }

      it { is_expected.not_to be_valid }
    end

    context "without content" do
      let(:content) { nil }

      it { is_expected.not_to be_valid }
    end

    context "with too-short content" do
      let(:content) { "abc" }

      it { is_expected.not_to be_valid }
    end
  end

  describe "#strip_title" do
    subject(:record) { create(:message_distribution, title: "  padded title  ") }

    it { expect(record.title).to eq("padded title") }
  end

  describe "status" do
    subject(:record) { create(:message_distribution) }

    it "defaults to draft" do
      expect(record).to be_draft
    end
  end

  describe "#sendable?" do
    subject { create(:message_distribution, status: status).sendable? }

    let(:status) { "draft" }

    it { is_expected.to be(true) }

    context "when already queued" do
      let(:status) { "queued" }

      it { is_expected.to be(false) }
    end

    context "when completed" do
      let(:status) { "completed" }

      it { is_expected.to be(false) }
    end
  end

  describe "#start_sending!" do
    subject(:start) { record.start_sending! }

    let(:record) { create(:message_distribution, status: "queued") }

    around do |example|
      Timecop.freeze(Time.parse("2026-06-08 10:00")) { example.run }
    end

    it "moves to sending and stamps started_at" do
      expect { start }.to change(record, :status).to("sending")
      expect(record.started_at).to eq(Time.current)
    end

    context "when started_at is already set" do
      let(:record) { create(:message_distribution, status: "sending", started_at: 1.hour.ago) }

      it "keeps the original started_at" do
        expect { start }.not_to change(record, :started_at)
      end
    end
  end

  describe "#complete!" do
    subject(:complete) { record.complete! }

    let(:record) { create(:message_distribution, status: "sending") }

    it "moves to completed and stamps finished_at" do
      expect { complete }.to change(record, :status).to("completed")
      expect(record.finished_at).to be_present
    end
  end

  describe "#refresh_counts!" do
    subject(:refresh) { record.refresh_counts! }

    let(:record) { create(:message_distribution) }

    before do
      create_list(:message_delivery, 2, :sent, message_distribution: record)
      create(:message_delivery, :failed, message_distribution: record)
    end

    it "recomputes delivered and failed counters from deliveries" do
      refresh

      expect(record.delivered_count).to eq(2)
      expect(record.failed_count).to eq(1)
    end
  end

  describe "#telegram_text" do
    subject(:text) { create(:message_distribution, title: title, content: content).telegram_text }

    let(:title) { "Internal label" }
    let(:content) { "**bold** body" }

    it "renders the content and omits the internal title" do
      expect(text).to eq(FormatChanger.markdown_to_telegram_markdown("**bold** body"))
      expect(text).not_to include("Internal label")
    end
  end
end
