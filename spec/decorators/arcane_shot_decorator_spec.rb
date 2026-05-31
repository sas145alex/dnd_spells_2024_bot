require "rails_helper"

RSpec.describe ArcaneShotDecorator do
  describe "#title" do
    subject(:title) { arcane_shot.decorate.title }

    let(:arcane_shot) { build(:arcane_shot, level: level, title: "Взрывной выстрел") }
    let(:level) { 2 }

    it { is_expected.to eq("[2] Взрывной выстрел") }

    context "with a different level" do
      let(:level) { 5 }

      it { is_expected.to eq("[5] Взрывной выстрел") }
    end
  end

  describe "#description_for_telegram" do
    subject(:description) { arcane_shot.decorate.description_for_telegram }

    let(:arcane_shot) { build(:arcane_shot, description: raw_description) }
    let(:raw_description) { "**Hello**" }

    it { is_expected.to eq(FormatChanger.markdown_to_telegram_markdown(raw_description).strip) }

    context "when the description is blank" do
      let(:raw_description) { "" }

      it { is_expected.to be_nil }
    end
  end

  describe "#global_search_title" do
    subject(:global_search_title) { arcane_shot.decorate.global_search_title }

    let(:arcane_shot) { build(:arcane_shot, level: 1, title: "выстрел") }

    it { is_expected.to eq("[#{ArcaneShot.model_name.human}] #{arcane_shot.decorate.title.capitalize}") }
  end

  describe "#parse_mode_for_telegram" do
    subject(:parse_mode) { arcane_shot.decorate.parse_mode_for_telegram }

    let(:arcane_shot) { build(:arcane_shot) }

    it { is_expected.to eq("HTML") }
  end
end
