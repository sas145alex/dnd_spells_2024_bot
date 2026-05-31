require "rails_helper"

RSpec.describe CharacteristicDecorator do
  describe "#title" do
    subject(:title) { characteristic.decorate.title }

    let(:characteristic) { build(:characteristic, title: "Сила") }

    it { is_expected.to eq("Сила") }
  end

  describe "#description_for_telegram" do
    subject(:description) { characteristic.decorate.description_for_telegram }

    let(:characteristic) { build(:characteristic, description: raw_description) }
    let(:raw_description) { "**Hello**" }

    it { is_expected.to eq(FormatChanger.markdown_to_telegram_markdown(raw_description).strip) }

    context "when the description is blank" do
      let(:raw_description) { "" }

      it { is_expected.to be_nil }
    end
  end

  describe "#global_search_title" do
    subject(:global_search_title) { characteristic.decorate.global_search_title }

    let(:characteristic) { build(:characteristic, title: "сила") }

    it { is_expected.to eq("[#{Characteristic.model_name.human}] #{characteristic.decorate.title.capitalize}") }
  end

  describe "#parse_mode_for_telegram" do
    subject(:parse_mode) { characteristic.decorate.parse_mode_for_telegram }

    let(:characteristic) { build(:characteristic) }

    it { is_expected.to eq("HTML") }
  end
end
