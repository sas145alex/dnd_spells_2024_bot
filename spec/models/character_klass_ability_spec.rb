require "rails_helper"

RSpec.describe CharacterKlassAbility do
  it_behaves_like "publishable", :character_klass_ability
  it_behaves_like "multisearchable", :character_klass_ability
  it_behaves_like "mentionable", :character_klass_ability
  it_behaves_like "who_did_itable", :character_klass_ability

  describe "associations" do
    it "requires a character_klass" do
      reflection = described_class.reflect_on_association(:character_klass)

      expect(reflection.macro).to eq(:belongs_to)
      expect(reflection.options[:optional]).to be(false)
    end
  end

  describe "validations" do
    subject(:record) { build(:character_klass_ability, title: title, description: description) }

    let(:title) { "Rage" }
    let(:description) { "A valid description." }

    it { is_expected.to be_valid }

    context "without a title" do
      let(:title) { nil }

      it { is_expected.not_to be_valid }
    end

    context "with a too-short title" do
      let(:title) { "ab" }

      it { is_expected.not_to be_valid }
    end

    context "without a description" do
      let(:description) { nil }

      it { is_expected.not_to be_valid }
    end

    context "without a character_klass" do
      subject(:record) { build(:character_klass_ability, character_klass: nil) }

      it { is_expected.not_to be_valid }
    end
  end

  describe "#normalize_levels" do
    subject(:record) { create(:character_klass_ability, levels: [1, nil, 3]) }

    it "compacts the levels array" do
      expect(record.levels).to eq([1, 3])
    end
  end

  describe ".ordered" do
    subject { described_class.ordered }

    let!(:second) { create(:character_klass_ability, title: "B title") }
    let!(:first) { create(:character_klass_ability, title: "A title") }

    it { is_expected.to eq([first, second]) }
  end
end
