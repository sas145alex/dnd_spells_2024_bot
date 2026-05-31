require "rails_helper"

RSpec.describe Creature do
  it_behaves_like "publishable", :creature
  it_behaves_like "multisearchable", :creature
  it_behaves_like "mentionable", :creature
  it_behaves_like "who_did_itable", :creature

  describe "validations" do
    subject(:record) do
      build(:creature, title: title, description: description, published_at: published_at)
    end

    let(:title) { "Goblin" }
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
    it "maps creature_type values" do
      expect(described_class.creature_types).to include(
        "humanoid" => "humanoid",
        "dragon" => "dragon",
        "undead" => "undead"
      )
    end

    it "maps creature_size values" do
      expect(described_class.creature_sizes).to include(
        "tiny" => "tiny",
        "medium" => "medium",
        "gargantuan" => "gargantuan"
      )
    end

    it "exposes the type_ prefix predicate" do
      expect(build(:creature, creature_type: :dragon)).to be_type_dragon
    end

    it "exposes the size_ prefix predicate" do
      expect(build(:creature, creature_size: :large)).to be_size_large
    end
  end

  describe "#recalculate_description_size" do
    subject(:record) { build(:creature, description: "abcd", original_description: "ab") }

    before { record.valid? }

    it { expect(record.description_size).to eq(4) }
    it { expect(record.original_description_size).to eq(2) }
  end

  describe ".ordered" do
    subject { described_class.ordered }

    let!(:second) { create(:creature, title: "B title") }
    let!(:first) { create(:creature, title: "A title") }

    it { is_expected.to eq([first, second]) }
  end
end
