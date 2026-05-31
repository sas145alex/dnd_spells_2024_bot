require "rails_helper"

RSpec.describe BotCommands::AllSpells do
  describe "#call" do
    subject(:result) { described_class.call(session: session, input_value: input_value, page: page) }

    let(:session) { {} }
    let(:input_value) { nil }
    let(:page) { nil }

    context "when listing published spells without filters" do
      let!(:cantrip) { create(:spell, :published, level: 0, title: "Брызги кислоты") }
      let!(:high_spell) { create(:spell, :published, level: 5, title: "Облако смерти") }
      let!(:unpublished) { create(:spell, level: 1, title: "Невидимка") }

      it "returns an :edit message listing only published spells ordered by level" do
        answer = result.first[:answer]

        expect(result.size).to eq(1)
        expect(result.first[:type]).to eq(:edit)
        expect(answer[:parse_mode]).to eq("HTML")
        expect(answer[:text]).to include("<b>Подходящих заклинаний:</b> 2")

        keyboard = answer[:reply_markup][:inline_keyboard]
        spell_buttons = keyboard.flatten.select { |b| b[:callback_data].to_s.start_with?("all_spells:gid") }
        expect(spell_buttons.map { |b| b[:text] }).to eq([cantrip.decorate.title, high_spell.decorate.title])
      end

      it "appends the filters and sections buttons" do
        keyboard = result.first[:answer][:reply_markup][:inline_keyboard]

        expect(keyboard).to include([{text: "Фильтры 📃", callback_data: "all_spells_filters:"}])
        expect(keyboard).to include([{text: "Ко всем разделам", callback_data: "sections:"}])
      end
    end

    context "when filters in the session narrow the results" do
      let!(:cantrip) { create(:spell, :published, level: 0, title: "Заговор") }
      let!(:level_three) { create(:spell, :published, level: 3, title: "Огненный шар") }
      let(:session) { {BotCommands::AllSpellsFilters::SESSION_KEY => {"levels" => "3"}} }

      it "only counts spells matching the level filter" do
        expect(result.first[:answer][:text]).to include("<b>Подходящих заклинаний:</b> 1")
      end
    end

    context "when a spell is selected by global id" do
      let(:spell) { create(:spell, :published, level: 3, title: "Огненный шар", original_title: "Fireball") }
      let(:input_value) { spell.to_global_id.to_s }

      it "renders the spell description with a go-back button" do
        answer = result.first[:answer]

        expect(result.first[:type]).to eq(:edit)
        expect(answer[:text]).to eq(spell.decorate.description_for_telegram)
        expect(answer[:reply_markup][:inline_keyboard]).to eq([[{text: "Назад", callback_data: "go_back:go_back"}]])
        expect(answer[:parse_mode]).to eq("HTML")
      end
    end
  end
end
