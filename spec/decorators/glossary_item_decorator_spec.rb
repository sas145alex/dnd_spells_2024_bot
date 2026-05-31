require "rails_helper"

RSpec.describe GlossaryItemDecorator do
  describe "#title" do
    subject(:title) { glossary_item.decorate.title }

    let(:glossary_item) { build(:glossary_item, title: item_title, category: category) }
    let(:item_title) { "Преимущество" }
    let(:category) { build(:glossary_category, title: "Механики") }

    it { is_expected.to eq("Преимущество [Механики]") }

    context "with a different category" do
      let(:category) { build(:glossary_category, title: "Состояния") }

      it { is_expected.to eq("Преимущество [Состояния]") }
    end
  end

  describe "#description_for_telegram" do
    subject(:description) { glossary_item.decorate.description_for_telegram }

    let(:glossary_item) { build(:glossary_item, description: raw_description) }
    let(:raw_description) { "**Hello**" }

    it { is_expected.to eq(FormatChanger.markdown_to_telegram_markdown(raw_description).strip) }

    context "when the description is blank" do
      let(:raw_description) { "" }

      it { is_expected.to be_nil }
    end
  end

  describe "#global_search_title" do
    subject(:global_search_title) { glossary_item.decorate.global_search_title }

    let(:glossary_item) do
      build(:glossary_item, title: "преимущество", category: build(:glossary_category, title: "Механики"))
    end

    it { is_expected.to eq("[#{GlossaryItem.model_name.human}] #{glossary_item.decorate.title.capitalize}") }
  end

  describe "#parse_mode_for_telegram" do
    subject(:parse_mode) { glossary_item.decorate.parse_mode_for_telegram }

    let(:glossary_item) { build(:glossary_item) }

    it { is_expected.to eq("HTML") }
  end
end
