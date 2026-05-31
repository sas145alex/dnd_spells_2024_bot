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
end
