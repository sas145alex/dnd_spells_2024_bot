require "rails_helper"

RSpec.describe MagicItem do
  it_behaves_like "publishable", :magic_item
  it_behaves_like "multisearchable", :magic_item
  it_behaves_like "mentionable", :magic_item
  it_behaves_like "who_did_itable", :magic_item

  describe "validations" do
    subject(:record) do
      build(:magic_item, title: title, description: description, published_at: published_at)
    end

    let(:title) { "Bag of Holding" }
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

  describe "enums" do
    it "maps category values" do
      expect(described_class.categories).to include(
        "wand" => "wand",
        "potion" => "potion",
        "magic_item" => "magic_item"
      )
    end

    it "maps rarity values" do
      expect(described_class.rarities).to include(
        "common" => "common",
        "legendary" => "legendary",
        "artifact" => "artifact"
      )
    end

    it "maps attunement values" do
      expect(described_class.attunements).to include(
        "unrequired" => "unrequired",
        "required" => "required"
      )
    end

    it "defaults rarity to common" do
      expect(described_class.new.rarity).to eq("common")
    end

    it "defaults attunement to unrequired" do
      expect(described_class.new.attunement).to eq("unrequired")
    end
  end

  describe ".ordered" do
    subject { described_class.ordered }

    let!(:second) { create(:magic_item, title: "B title") }
    let!(:first) { create(:magic_item, title: "A title") }

    it { is_expected.to eq([first, second]) }
  end
end
