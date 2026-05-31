require "rails_helper"

RSpec.describe PsionicPowerDecorator do
  describe "#title" do
    subject(:title) { psionic_power.decorate.title }

    let(:psionic_power) { build(:psionic_power, level: level, title: "Телекинез") }
    let(:level) { 3 }

    it { is_expected.to eq("[3] Телекинез") }

    context "with a different level" do
      let(:level) { 7 }

      it { is_expected.to eq("[7] Телекинез") }
    end
  end

  describe "#description_for_telegram" do
    subject(:description) { psionic_power.decorate.description_for_telegram }

    let(:psionic_power) { build(:psionic_power, description: raw_description) }
    let(:raw_description) { "**Hello**" }

    it { is_expected.to eq(FormatChanger.markdown_to_telegram_markdown(raw_description).strip) }

    context "when the description is blank" do
      let(:raw_description) { "" }

      it { is_expected.to be_nil }
    end
  end

  describe "#global_search_title" do
    subject(:global_search_title) { psionic_power.decorate.global_search_title }

    let(:psionic_power) { build(:psionic_power, level: 1, title: "телекинез") }

    it { is_expected.to eq("[#{PsionicPower.model_name.human}] #{psionic_power.decorate.title.capitalize}") }
  end

  describe "#parse_mode_for_telegram" do
    subject(:parse_mode) { psionic_power.decorate.parse_mode_for_telegram }

    let(:psionic_power) { build(:psionic_power) }

    it { is_expected.to eq("HTML") }
  end
end
