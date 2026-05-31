require "rails_helper"

RSpec.describe BotCommands::AllSpellsFilters::DisplayFilters do
  describe "#call" do
    subject(:text) { described_class.call(store) }

    context "when no filters are set" do
      let(:store) { {} }

      it "reports zero filters with no detail lines" do
        expect(text).to eq("<b>Фильтров выбрано: 0</b>\n")
      end
    end

    context "when a level filter is set" do
      let(:store) { {"levels" => "3"} }

      it "renders the level value" do
        expect(text).to eq("<b>Фильтров выбрано: 1</b>\n1. <b>Уровень</b>: <i>3</i>")
      end
    end

    context "when the level is a cantrip" do
      let(:store) { {"levels" => "0"} }

      it "renders the cantrip label" do
        expect(text).to include("<i>Заговор</i>")
      end
    end

    context "when a school filter is set" do
      let(:store) { {"schools" => "evocation"} }

      it "renders the humanized school name" do
        expect(text).to eq("<b>Фильтров выбрано: 1</b>\n1. <b>Школа</b>: <i>Воплощение</i>")
      end
    end

    context "when a boolean filter is set" do
      let(:store) { {"ritual" => "true"} }

      it "renders the localized boolean" do
        expect(text).to eq("<b>Фильтров выбрано: 1</b>\n1. <b>Ритуал</b>: <i>Да</i>")
      end
    end

    context "when a klass filter is set" do
      let(:klass) { create(:character_klass, title: "Волшебник") }
      let(:store) { {"klasses" => klass.id.to_s} }

      it "renders the klass title" do
        expect(text).to eq("<b>Фильтров выбрано: 1</b>\n1. <b>Классы</b>: <i>Волшебник</i>")
      end
    end

    context "when several filters are set" do
      let(:store) { {"levels" => "3", "schools" => "necromancy"} }

      it "numbers each filter line" do
        expect(text).to eq(
          "<b>Фильтров выбрано: 2</b>\n1. <b>Уровень</b>: <i>3</i>\n2. <b>Школа</b>: <i>Некромантия</i>"
        )
      end
    end
  end
end
