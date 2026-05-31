require "rails_helper"

RSpec.describe PlanDecorator do
  describe "#title" do
    subject(:title) { plan.decorate.title }

    let(:plan) { build(:plan, level: level, title: "Огненная защита") }
    let(:level) { 2 }

    it { is_expected.to eq("[2] Огненная защита") }

    context "with a different level" do
      let(:level) { 6 }

      it { is_expected.to eq("[6] Огненная защита") }
    end
  end

  describe "#description_for_telegram" do
    subject(:description) { plan.decorate.description_for_telegram }

    let(:plan) { build(:plan, description: raw_description) }
    let(:raw_description) { "**Hello**" }

    it { is_expected.to eq(FormatChanger.markdown_to_telegram_markdown(raw_description).strip) }

    context "when the description is blank" do
      let(:raw_description) { "" }

      it { is_expected.to be_nil }
    end
  end

  describe "#global_search_title" do
    subject(:global_search_title) { plan.decorate.global_search_title }

    let(:plan) { build(:plan, level: 1, title: "защита") }

    it { is_expected.to eq("[#{Plan.model_name.human}] #{plan.decorate.title.capitalize}") }
  end

  describe "#parse_mode_for_telegram" do
    subject(:parse_mode) { plan.decorate.parse_mode_for_telegram }

    let(:plan) { build(:plan) }

    it { is_expected.to eq("HTML") }
  end
end
