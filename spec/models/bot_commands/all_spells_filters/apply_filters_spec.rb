require "rails_helper"

RSpec.describe BotCommands::AllSpellsFilters::ApplyFilters do
  describe "#call" do
    subject(:filtered) { described_class.call(scope: scope, filters: filters) }

    let(:scope) { Spell.all }
    let(:filters) { {} }

    context "when there are no filters" do
      let!(:spell) { create(:spell, level: 1) }

      it "returns the scope unchanged" do
        expect(filtered).to contain_exactly(spell)
      end
    end

    context "when filtering by level" do
      let!(:matching) { create(:spell, level: 3) }
      let!(:other) { create(:spell, level: 1) }
      let(:filters) { {"levels" => "3"} }

      it "keeps only spells of that level" do
        expect(filtered).to contain_exactly(matching)
      end
    end

    context "when filtering by school" do
      let!(:matching) { create(:spell, level: 1, school: :evocation) }
      let!(:other) { create(:spell, level: 1, school: :illusion) }
      let(:filters) { {"schools" => "evocation"} }

      it "keeps only spells of that school" do
        expect(filtered).to contain_exactly(matching)
      end
    end

    context "when filtering by a boolean attribute" do
      let!(:ritual_spell) { create(:spell, level: 1, ritual: true) }
      let!(:non_ritual_spell) { create(:spell, level: 1, ritual: false) }
      let(:filters) { {"ritual" => "true"} }

      it "keeps only spells matching the boolean" do
        expect(filtered).to contain_exactly(ritual_spell)
      end
    end

    context "when filtering by character klass" do
      let(:klass) { create(:character_klass) }
      let!(:matching) { create(:spell, level: 1) }
      let!(:other) { create(:spell, level: 1) }
      let(:filters) { {"klasses" => klass.id.to_s} }

      before { create(:spells_character_klass, spell: matching, character_klass: klass) }

      it "keeps only spells linked to that klass" do
        expect(filtered).to contain_exactly(matching)
      end
    end

    context "when multiple filters are combined" do
      let!(:matching) { create(:spell, level: 2, school: :necromancy) }
      let!(:wrong_school) { create(:spell, level: 2, school: :evocation) }
      let!(:wrong_level) { create(:spell, level: 1, school: :necromancy) }
      let(:filters) { {"levels" => "2", "schools" => "necromancy"} }

      it "applies every filter" do
        expect(filtered).to contain_exactly(matching)
      end
    end
  end
end
