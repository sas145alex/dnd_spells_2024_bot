RSpec.describe Mention::GenerateOptionsForSelect do
  subject { described_class.call(mentionable_klass: mentionable_klass) }

  context "when mentionable klass is nil" do
    let(:mentionable_klass) { nil }

    it "returns an empty array" do
      expect(subject).to eq([])
    end
  end

  context "when mentionable klass is Spell" do
    let(:mentionable_klass) { Spell }

    let!(:mentionable_entity) { create(:spell) }

    let(:expected_result) do
      [
        {
          id: mentionable_entity.id,
          text: mentionable_entity.title
        }
      ]
    end

    it "returns an ordered array of specified entities" do
      expect(subject).to eq(expected_result)
    end
  end

  context "when mentionable klass is Creature" do
    let(:mentionable_klass) { Creature }

    let!(:mentionable_entity) { create(:creature) }

    let(:expected_result) do
      [
        {
          id: mentionable_entity.id,
          text: mentionable_entity.title
        }
      ]
    end

    it "returns an ordered array of specified entities" do
      expect(subject).to eq(expected_result)
    end
  end

  context "when mentionable klass is GlossaryItem" do
    let(:mentionable_klass) { GlossaryItem }

    let!(:mentionable_entity) { create(:glossary_item) }

    let(:expected_result) do
      [
        {
          id: mentionable_entity.id,
          text: mentionable_entity.title
        }
      ]
    end

    it "returns an ordered array of specified entities" do
      expect(subject).to eq(expected_result)
    end
  end

  context "when mentionable klas is WildMagic" do
    let(:mentionable_klass) { WildMagic }

    let!(:mentionable_entity) { create(:wild_magic, roll: 1..100) }

    let(:expected_result) do
      [
        {
          id: mentionable_entity.id,
          text: "Дикая магия (1..100)"
        }
      ]
    end

    it "returns an ordered array of specified entities" do
      expect(subject).to eq(expected_result)
    end
  end
end
