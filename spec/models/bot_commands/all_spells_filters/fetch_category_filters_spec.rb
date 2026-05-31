require "rails_helper"

RSpec.describe BotCommands::AllSpellsFilters::FetchCategoryFilters do
  describe "#call" do
    subject(:result) { described_class.call(filter_type, selected_value) }

    let(:selected_value) { nil }

    def callbacks_from(answer)
      answer[:reply_markup][:inline_keyboard].flatten.map { |b| b[:callback_data] }
    end

    context "when fetching levels" do
      let(:filter_type) { "levels" }

      it "offers a button per spell level plus a back button" do
        expect(result[:parse_mode]).to eq("HTML")
        expect(result[:text]).to include("Выбери уровень заклинаний")

        callbacks = callbacks_from(result)
        Spell::LEVELS.each { |level| expect(callbacks).to include("all_spells_set_filters:levels__#{level}") }
        expect(result[:reply_markup][:inline_keyboard].last).to eq(
          [{text: "Назад", callback_data: "all_spells_filters:"}]
        )
      end
    end

    context "when a level is already selected" do
      let(:filter_type) { "levels" }
      let(:selected_value) { 3 }

      it "marks the selected level button" do
        button = result[:reply_markup][:inline_keyboard].flatten.find do |b|
          b[:callback_data] == "all_spells_set_filters:levels__3"
        end

        expect(button[:text]).to eq("3 ✅")
      end
    end

    context "when fetching schools" do
      let(:filter_type) { "schools" }

      it "offers a button per school" do
        callbacks = callbacks_from(result)

        Spell.schools.each_key { |school| expect(callbacks).to include("all_spells_set_filters:schools__#{school}") }
      end
    end

    context "when fetching klasses" do
      let(:filter_type) { "klasses" }
      let!(:base_klass) { create(:character_klass, title: "Бард") }
      let!(:subklass) { create(:character_klass, title: "Колледж", parent_klass: base_klass) }

      it "offers only base klasses" do
        callbacks = callbacks_from(result)

        expect(callbacks).to include("all_spells_set_filters:klasses__#{base_klass.id}")
        expect(callbacks).not_to include("all_spells_set_filters:klasses__#{subklass.id}")
      end
    end

    context "when fetching a boolean filter" do
      let(:filter_type) { "ritual" }

      it "offers true/false options" do
        callbacks = callbacks_from(result)

        expect(callbacks).to include("all_spells_set_filters:ritual__true", "all_spells_set_filters:ritual__false")
      end
    end

    context "when the filter type is unknown" do
      let(:filter_type) { "bogus" }

      it "returns an invalid-input message" do
        expect(result).to eq(
          text: "Невалидный ввод при выборе фильтра - bogus",
          parse_mode: "HTML"
        )
      end
    end
  end
end
