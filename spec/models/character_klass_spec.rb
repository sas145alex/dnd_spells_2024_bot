require "rails_helper"

RSpec.describe CharacterKlass do
  it_behaves_like "publishable", :character_klass
  it_behaves_like "multisearchable", :character_klass
  it_behaves_like "mentionable", :character_klass
  it_behaves_like "segmentable", :character_klass
  it_behaves_like "who_did_itable", :character_klass

  describe "associations" do
    it "optionally belongs to a parent_klass" do
      reflection = described_class.reflect_on_association(:parent_klass)

      expect(reflection.macro).to eq(:belongs_to)
      expect(reflection.options[:class_name]).to eq("CharacterKlass")
      expect(reflection.options[:optional]).to be(true)
    end

    it "has many spells through spells_character_klasses" do
      reflection = described_class.reflect_on_association(:spells)

      expect(reflection.macro).to eq(:has_many)
      expect(reflection.options[:through]).to eq(:spells_character_klasses)
    end
  end

  describe "validations" do
    subject(:record) { build(:character_klass, title: title) }

    let(:title) { "Wizard" }

    it { is_expected.to be_valid }

    context "without a title" do
      let(:title) { nil }

      it { is_expected.not_to be_valid }
    end

    context "with a too-short title" do
      let(:title) { "ab" }

      it { is_expected.not_to be_valid }
    end
  end

  describe "scopes" do
    let!(:base) { create(:character_klass, title: "Base klass") }
    let!(:sub) { create(:character_klass, title: "Sub klass", parent_klass: base) }

    describe ".base_klasses" do
      subject { described_class.base_klasses }

      it { is_expected.to include(base) }
      it { is_expected.not_to include(sub) }
    end

    describe ".subklasses" do
      subject { described_class.subklasses }

      it { is_expected.to include(sub) }
      it { is_expected.not_to include(base) }
    end

    describe ".ordered" do
      subject { described_class.ordered.where(id: [base.id, sub.id]) }

      it { is_expected.to eq([base, sub]) }
    end
  end

  describe "#base_klass?" do
    subject { record.base_klass? }

    context "with no parent" do
      let(:record) { build(:character_klass) }

      it { is_expected.to be(true) }
    end

    context "with a parent" do
      let(:record) { build(:character_klass, parent_klass: create(:character_klass)) }

      it { is_expected.to be(false) }
    end
  end

  describe "#main_character_klass" do
    subject { record.main_character_klass }

    let(:parent) { create(:character_klass) }

    context "when it is a base klass" do
      let(:record) { create(:character_klass) }

      it { is_expected.to eq(record) }
    end

    context "when it is a subklass" do
      let(:record) { create(:character_klass, parent_klass: parent) }

      it { is_expected.to eq(parent) }
    end
  end

  describe "#use_invocations?" do
    subject { record.use_invocations? }

    context "for the Warlock" do
      let(:record) { build(:character_klass, title: "Колдун", original_title: "Warlock") }

      it { is_expected.to be(true) }
    end

    context "for another klass" do
      let(:record) { build(:character_klass, title: "Wizard", original_title: "Wizard") }

      it { is_expected.to be(false) }
    end
  end

  describe "#use_metamagic?" do
    subject { record.use_metamagic? }

    context "for the Sorcerer" do
      let(:record) { build(:character_klass, title: "Чародей", original_title: "Sorcerer") }

      it { is_expected.to be(true) }
    end
  end

  describe "#use_maneuvers?" do
    subject { record.use_maneuvers? }

    context "for the Battle Master" do
      let(:record) do
        build(:character_klass, title: "Мастер боевых искусств", original_title: "Battle Master")
      end

      it { is_expected.to be(true) }
    end
  end

  describe "#use_arcane_shots?" do
    subject { record.use_arcane_shots? }

    context "for the Arcane Archer" do
      let(:record) do
        build(:character_klass, title: "Арканный лучник", original_title: "Arcane Archer")
      end

      it { is_expected.to be(true) }
    end
  end

  describe "#has_spells?" do
    subject { klass.has_spells? }

    let(:klass) { create(:character_klass) }

    context "without spells" do
      it { is_expected.to be(false) }
    end

    context "with a spell" do
      before { create(:spells_character_klass, character_klass: klass) }

      it { is_expected.to be(true) }
    end
  end

  describe "#use_parent_description?" do
    subject { record.use_parent_description? }

    let(:parent) { create(:character_klass) }

    context "for a base klass" do
      let(:record) { create(:character_klass) }

      it { is_expected.to be(false) }
    end

    context "for a subklass with an empty description" do
      let(:record) { create(:character_klass, parent_klass: parent, description: "") }

      it { is_expected.to be(true) }
    end

    context "for a subklass with a description" do
      let(:record) { create(:character_klass, parent_klass: parent, description: "Has text") }

      it { is_expected.to be(false) }
    end
  end
end
