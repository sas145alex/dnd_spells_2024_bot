require "rails_helper"

RSpec.describe SpellsCharacterKlass do
  describe "associations" do
    it "belongs to a spell" do
      reflection = described_class.reflect_on_association(:spell)

      expect(reflection.macro).to eq(:belongs_to)
    end

    it "belongs to a character_klass" do
      reflection = described_class.reflect_on_association(:character_klass)

      expect(reflection.macro).to eq(:belongs_to)
    end
  end

  describe "validations" do
    subject(:record) { build(:spells_character_klass) }

    it { is_expected.to be_valid }

    context "without a spell" do
      subject(:record) { build(:spells_character_klass, spell: nil) }

      it { is_expected.not_to be_valid }
    end

    context "without a character_klass" do
      subject(:record) { build(:spells_character_klass, character_klass: nil) }

      it { is_expected.not_to be_valid }
    end
  end
end
