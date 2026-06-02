require "rails_helper"

RSpec.describe CharacterKlassDecorator do
  describe "#title" do
    subject(:title) { character_klass.decorate.title }

    context "with a base klass (no parent)" do
      let(:character_klass) { build(:character_klass, title: "Воин") }

      it { is_expected.to eq("Воин") }
    end

    context "with a subklass" do
      let(:parent_klass) { create(:character_klass, title: "Воин") }
      let(:character_klass) { build(:character_klass, title: "Чемпион", parent_klass: parent_klass) }

      it { is_expected.to eq("Воин - Чемпион") }
    end
  end

  describe "#description_for_telegram" do
    subject(:description) { character_klass.decorate.description_for_telegram }

    let(:character_klass) { build(:character_klass, description: raw_description) }
    let(:raw_description) { "**Hello**" }

    it { is_expected.to eq(FormatChanger.markdown_to_telegram_markdown(raw_description).strip) }

    context "when the description is blank" do
      let(:raw_description) { "" }

      it { is_expected.to be_nil }
    end

    context "when a subklass has no description of its own" do
      let(:parent_klass) { create(:character_klass, description: "**Parent text**") }
      let(:character_klass) { build(:character_klass, description: "", parent_klass: parent_klass) }

      it "inherits the parent klass description" do
        is_expected.to eq(FormatChanger.markdown_to_telegram_markdown("**Parent text**").strip)
      end
    end
  end

  describe "#global_search_title" do
    subject(:global_search_title) { character_klass.decorate.global_search_title }

    let(:character_klass) { build(:character_klass, title: "воин") }

    it { is_expected.to eq("[#{CharacterKlass.model_name.human}] #{character_klass.decorate.title.capitalize}") }
  end

  describe "#parse_mode_for_telegram" do
    subject(:parse_mode) { character_klass.decorate.parse_mode_for_telegram }

    let(:character_klass) { build(:character_klass) }

    it { is_expected.to eq("HTML") }
  end
end
