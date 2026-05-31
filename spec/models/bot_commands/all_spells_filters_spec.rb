require "rails_helper"

RSpec.describe BotCommands::AllSpellsFilters do
  describe "#call" do
    subject(:result) { described_class.call(session: session, input_value: input_value, step: step) }

    let(:session) { {} }
    let(:input_value) { nil }
    let(:step) { nil }

    context "when no category is selected (default categories view)" do
      it "returns an :edit message listing all filter categories" do
        answer = result.first[:answer]

        expect(result.size).to eq(1)
        expect(result.first[:type]).to eq(:edit)
        expect(answer[:parse_mode]).to eq("HTML")
        expect(answer[:text]).to include("Выбери категорию фильтра:")

        callbacks = answer[:reply_markup][:inline_keyboard].flatten.map { |b| b[:callback_data] }
        described_class::FILTER_CATEGORIES.each_key do |category|
          expect(callbacks).to include("all_spells_filters:#{category}")
        end
      end

      it "shows the link to all spells and no reset button when no filters set" do
        keyboard = result.first[:answer][:reply_markup][:inline_keyboard]

        expect(keyboard.last).to eq([{text: "Поиск заклинаний ✨", callback_data: "all_spells:"}])
        expect(keyboard.flatten.map { |b| b[:callback_data] }).not_to include("all_spells_set_filters:reset")
      end
    end

    context "when filters are already set" do
      let(:session) { {described_class::SESSION_KEY => {"levels" => "3"}} }

      it "marks the selected category and shows a reset button" do
        keyboard = result.first[:answer][:reply_markup][:inline_keyboard]
        flat = keyboard.flatten

        levels_button = flat.find { |b| b[:callback_data] == "all_spells_filters:levels" }
        expect(levels_button[:text]).to eq("Уровень ✅")
        expect(flat).to include(hash_including(callback_data: "all_spells_set_filters:reset"))
      end
    end

    context "when a category is selected" do
      let(:input_value) { "levels" }

      it "delegates to FetchCategoryFilters for that category" do
        expected = described_class::FetchCategoryFilters.call("levels", nil, separator: described_class::FILTER_VALUE_SEPARATOR)

        expect(result).to eq([{type: :edit, answer: expected}])
      end
    end

    context "when setting a filter (step == :set_filter)" do
      let(:step) { :set_filter }
      let(:input_value) { "levels__5" }

      it "writes the filter into the session and re-renders categories" do
        result

        expect(session[described_class::SESSION_KEY]).to eq("levels" => "5")
        expect(result.first[:type]).to eq(:edit)
      end
    end

    context "when toggling an already-set filter off" do
      let(:step) { :set_filter }
      let(:input_value) { "levels__5" }
      let(:session) { {described_class::SESSION_KEY => {"levels" => "5"}} }

      it "removes the filter and clears the session key when empty" do
        result

        expect(session).not_to have_key(described_class::SESSION_KEY)
      end
    end

    context "when resetting filters" do
      let(:step) { :set_filter }
      let(:input_value) { "reset" }
      let(:session) { {described_class::SESSION_KEY => {"levels" => "5"}} }

      it "deletes the filters session key" do
        result

        expect(session).not_to have_key(described_class::SESSION_KEY)
      end
    end
  end
end
