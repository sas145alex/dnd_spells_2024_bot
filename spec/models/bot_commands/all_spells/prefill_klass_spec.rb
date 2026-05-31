require "rails_helper"

RSpec.describe BotCommands::AllSpells::PrefillKlass do
  describe "#call" do
    subject(:result) { described_class.call(session: session, input_value: input_value) }

    let(:session) { {} }

    context "when the selected object is a base character klass" do
      let(:klass) { create(:character_klass, title: "Волшебник") }
      let(:input_value) { klass.to_global_id.to_s }

      it "sets the klasses filter to the klass id in the session" do
        result

        expect(session[BotCommands::AllSpellsFilters::SESSION_KEY]).to eq("klasses" => klass.id)
      end

      it "delegates to AllSpells and returns its spell listing" do
        expect(result).to eq(BotCommands::AllSpells.call(input_value: nil, session: session))
      end
    end

    context "when the selected object is a subklass" do
      let(:base_klass) { create(:character_klass, title: "Бард") }
      let(:klass) { create(:character_klass, title: "Колледж знаний", parent_klass: base_klass) }
      let(:input_value) { klass.to_global_id.to_s }

      it "uses the parent (main) klass id for the filter" do
        result

        expect(session[BotCommands::AllSpellsFilters::SESSION_KEY]).to eq("klasses" => base_klass.id)
      end
    end

    context "when there are pre-existing filters" do
      let(:klass) { create(:character_klass, title: "Жрец") }
      let(:input_value) { klass.to_global_id.to_s }
      let(:session) { {BotCommands::AllSpellsFilters::SESSION_KEY => {"levels" => "3"}} }

      it "replaces existing filters with only the klass filter" do
        result

        expect(session[BotCommands::AllSpellsFilters::SESSION_KEY]).to eq("klasses" => klass.id)
      end
    end

    context "when the selected object is not a character klass" do
      let(:input_value) { create(:spell).to_global_id.to_s }

      it "returns the invalid-input message and leaves the session untouched" do
        expect(result).to eq(
          [{type: :message, answer: {text: "Невалидный ввод", reply_markup: {}, parse_mode: "HTML"}}]
        )
        expect(session).to be_empty
      end
    end
  end
end
