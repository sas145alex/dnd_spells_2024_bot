require "rails_helper"

RSpec.describe ToolDecorator do
  describe "#title" do
    subject(:title) { tool.decorate.title }

    let(:tool) { build(:tool, title: "Воровские инструменты") }

    it { is_expected.to eq("Воровские инструменты") }
  end

  describe "#description_for_telegram" do
    subject(:description) { tool.decorate.description_for_telegram }

    let(:tool) { build(:tool, description: raw_description) }
    let(:raw_description) { "**Hello**" }

    it { is_expected.to eq(FormatChanger.markdown_to_telegram_markdown(raw_description).strip) }

    context "when the description is blank" do
      let(:raw_description) { "" }

      it { is_expected.to be_nil }
    end
  end

  describe "#global_search_title" do
    subject(:global_search_title) { tool.decorate.global_search_title }

    let(:tool) { build(:tool, title: "воровские инструменты") }

    it { is_expected.to eq("[#{Tool.model_name.human}] #{tool.decorate.title.capitalize}") }
  end

  describe "#parse_mode_for_telegram" do
    subject(:parse_mode) { tool.decorate.parse_mode_for_telegram }

    let(:tool) { build(:tool) }

    it { is_expected.to eq("HTML") }
  end
end
