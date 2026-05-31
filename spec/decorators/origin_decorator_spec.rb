require "rails_helper"

RSpec.describe OriginDecorator do
  describe "#title" do
    subject(:title) { origin.decorate.title }

    let(:origin) { build(:origin, title: "Солдат") }

    it { is_expected.to eq("Солдат") }
  end

  describe "#description_for_telegram" do
    subject(:description) { origin.decorate.description_for_telegram }

    let(:origin) { build(:origin, description: raw_description) }
    let(:raw_description) { "**Hello**" }

    it { is_expected.to eq(FormatChanger.markdown_to_telegram_markdown(raw_description).strip) }

    context "when the description is blank" do
      let(:raw_description) { "" }

      it { is_expected.to be_nil }
    end
  end

  describe "#global_search_title" do
    subject(:global_search_title) { origin.decorate.global_search_title }

    let(:origin) { build(:origin, title: "солдат") }

    it { is_expected.to eq("[#{Origin.model_name.human}] #{origin.decorate.title.capitalize}") }
  end

  describe "#parse_mode_for_telegram" do
    subject(:parse_mode) { origin.decorate.parse_mode_for_telegram }

    let(:origin) { build(:origin) }

    it { is_expected.to eq("HTML") }
  end
end
