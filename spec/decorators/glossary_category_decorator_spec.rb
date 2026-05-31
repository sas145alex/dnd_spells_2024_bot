require "rails_helper"

RSpec.describe GlossaryCategoryDecorator do
  describe "#title" do
    subject(:title) { glossary_category.decorate.title }

    let(:glossary_category) { build(:glossary_category, title: "Механики") }

    it { is_expected.to eq("Механики") }
  end

  describe "#global_search_title" do
    subject(:global_search_title) { glossary_category.decorate.global_search_title }

    let(:glossary_category) { build(:glossary_category, title: "механики") }

    it { is_expected.to eq("[#{GlossaryCategory.model_name.human}] #{glossary_category.decorate.title.capitalize}") }
  end

  describe "#parse_mode_for_telegram" do
    subject(:parse_mode) { glossary_category.decorate.parse_mode_for_telegram }

    let(:glossary_category) { build(:glossary_category) }

    it { is_expected.to eq("HTML") }
  end
end
