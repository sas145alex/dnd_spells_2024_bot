require "rails_helper"

RSpec.describe EquipmentItem do
  it_behaves_like "publishable", :equipment_item
  it_behaves_like "multisearchable", :equipment_item
  it_behaves_like "mentionable", :equipment_item
  it_behaves_like "who_did_itable", :equipment_item

  describe "validations" do
    subject(:record) do
      build(:equipment_item, title: title, description: description, published_at: published_at)
    end

    let(:title) { "Longsword" }
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

  describe "item_type enum" do
    it "maps representative values" do
      expect(described_class.item_types).to include(
        "simple_melee" => "simple_melee",
        "heavy_armor" => "heavy_armor",
        "poison" => "poison"
      )
    end

    it "defaults to other" do
      expect(described_class.new.item_type).to eq("other")
    end
  end

  describe ".weapon_item_types" do
    subject { described_class.weapon_item_types }

    it { is_expected.to include(:simple_melee, :martial_ranged, :explosive) }
    it { is_expected.not_to include(:shield) }
  end

  describe ".armor_item_types" do
    subject { described_class.armor_item_types }

    it { is_expected.to include(:no_armor, :heavy_armor, :shield) }
  end

  describe ".general_item_types" do
    subject { described_class.general_item_types }

    it { is_expected.to include(:alchemy, :poison, :other) }
    it { is_expected.not_to include(:simple_melee) }
  end

  describe ".ordered" do
    subject { described_class.ordered }

    let!(:second) { create(:equipment_item, title: "B title") }
    let!(:first) { create(:equipment_item, title: "A title") }

    it { is_expected.to eq([first, second]) }
  end
end
