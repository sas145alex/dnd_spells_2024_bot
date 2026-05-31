require "rails_helper"

RSpec.describe Presenters::CharacterAbilitiesPresenter do
  subject(:variants) { described_class.call(character_klass: character_klass) }

  let(:character_klass) { create(:character_klass) }

  context "when there are no abilities" do
    it { is_expected.to eq([]) }
  end

  context "when an ability has no levels" do
    let!(:ability) do
      create(
        :character_klass_ability,
        character_klass: character_klass,
        levels: [],
        published_at: Time.current
      )
    end

    it "skips it" do
      expect(variants).to eq([])
    end
  end

  context "when an ability is not published" do
    let!(:ability) do
      create(
        :character_klass_ability,
        character_klass: character_klass,
        levels: [1],
        published_at: nil
      )
    end

    it "skips it" do
      expect(variants).to eq([])
    end
  end

  context "when a published ability has multiple levels" do
    let!(:ability) do
      create(
        :character_klass_ability,
        character_klass: character_klass,
        title: "Rage",
        levels: [3, 1],
        published_at: Time.current
      )
    end

    it "returns one variant per level" do
      expect(variants.size).to eq(2)
    end

    it "sorts the variants by level" do
      expect(variants.map(&:level)).to eq([1, 3])
    end

    it "builds titles prefixed with the level" do
      expect(variants.map(&:title)).to eq(["[1] Rage", "[3] Rage"])
    end

    it "exposes the decorated ability global id" do
      expect(variants.map(&:to_global_id)).to all(eq(ability.decorate.to_global_id))
    end
  end

  context "when the klass is a subklass" do
    let(:parent_klass) { create(:character_klass) }
    let(:character_klass) { create(:character_klass, parent_klass: parent_klass) }

    let!(:parent_ability) do
      create(
        :character_klass_ability,
        character_klass: parent_klass,
        title: "Inherited",
        levels: [2],
        published_at: Time.current
      )
    end
    let!(:own_ability) do
      create(
        :character_klass_ability,
        character_klass: character_klass,
        title: "Own",
        levels: [5],
        published_at: Time.current
      )
    end

    it "includes abilities from both the subklass and the parent" do
      expect(variants.map(&:level)).to eq([2, 5])
    end

    it "prefixes subklass ability titles with the emoji" do
      own_variant = variants.find { |variant| variant.level == 5 }

      expect(own_variant.title).to include(described_class::EMOJI)
    end
  end
end
