require "rails_helper"

RSpec.describe RaceDecorator do
  describe "#title" do
    subject(:title) { race.decorate.title }

    let(:race) { build(:race, title: "Эльф") }

    it { is_expected.to eq("Эльф") }
  end

  describe "#description_for_telegram" do
    subject(:description) { race.decorate.description_for_telegram }

    let(:race) { build(:race, description: raw_description) }
    let(:raw_description) { "**Hello**" }

    it { is_expected.to eq(FormatChanger.markdown_to_telegram_markdown(raw_description).strip) }

    context "when the description is blank" do
      let(:raw_description) { "" }

      it { is_expected.to be_nil }
    end
  end

  describe "#global_search_title" do
    subject(:global_search_title) { race.decorate.global_search_title }

    let(:race) { build(:race, title: "эльф") }

    it { is_expected.to eq("[#{Race.model_name.human}] #{race.decorate.title.capitalize}") }
  end

  describe "#parse_mode_for_telegram" do
    subject(:parse_mode) { race.decorate.parse_mode_for_telegram }

    let(:race) { build(:race) }

    it { is_expected.to eq("HTML") }
  end
end
