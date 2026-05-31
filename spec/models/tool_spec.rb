require "rails_helper"

RSpec.describe Tool do
  it_behaves_like "publishable", :tool
  it_behaves_like "multisearchable", :tool
  it_behaves_like "mentionable", :tool
  it_behaves_like "who_did_itable", :tool

  describe "validations" do
    subject(:record) do
      build(:tool, title: title, description: description, published_at: published_at)
    end

    let(:title) { "Thieves' Tools" }
    let(:description) { "A valid description." }
    let(:published_at) { nil }

    it { is_expected.to be_valid }

    context "without a title" do
      let(:title) { nil }

      it { is_expected.not_to be_valid }
    end

    context "with a too-short title" do
      let(:title) { "ab" }

      it { is_expected.not_to be_valid }
    end

    context "when published without a description" do
      let(:published_at) { Time.current }
      let(:description) { nil }

      it { is_expected.not_to be_valid }
    end

    context "when unpublished without a description" do
      let(:description) { nil }

      it { is_expected.to be_valid }
    end
  end

  describe "category enum" do
    it "maps values" do
      expect(described_class.categories).to eq(
        "other" => "other",
        "handcraft" => "handcraft"
      )
    end
  end

  describe ".ordered" do
    subject { described_class.ordered }

    let!(:second) { create(:tool, title: "B title") }
    let!(:first) { create(:tool, title: "A title") }

    it { is_expected.to eq([first, second]) }
  end
end
