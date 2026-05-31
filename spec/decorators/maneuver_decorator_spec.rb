require "rails_helper"

RSpec.describe ManeuverDecorator do
  describe "#title" do
    subject(:title) { maneuver.decorate.title }

    let(:maneuver) { build(:maneuver, title: "Атака с ходу") }

    it { is_expected.to eq("Атака с ходу") }
  end

  describe "#description_for_telegram" do
    subject(:description) { maneuver.decorate.description_for_telegram }

    let(:maneuver) { build(:maneuver, description: raw_description) }
    let(:raw_description) { "**Hello**" }

    it { is_expected.to eq(FormatChanger.markdown_to_telegram_markdown(raw_description).strip) }

    context "when the description is blank" do
      let(:raw_description) { "" }

      it { is_expected.to be_nil }
    end
  end

  describe "#global_search_title" do
    subject(:global_search_title) { maneuver.decorate.global_search_title }

    let(:maneuver) { build(:maneuver, title: "атака с ходу") }

    it { is_expected.to eq("[#{Maneuver.model_name.human}] #{maneuver.decorate.title.capitalize}") }
  end

  describe "#parse_mode_for_telegram" do
    subject(:parse_mode) { maneuver.decorate.parse_mode_for_telegram }

    let(:maneuver) { build(:maneuver) }

    it { is_expected.to eq("HTML") }
  end
end
