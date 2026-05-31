require "rails_helper"

RSpec.describe SpellDecorator do
  describe "#title" do
    subject(:title) { spell.decorate.title }

    let(:spell) { build(:spell, level: level, title: spell_title, original_title: original_title) }
    let(:level) { 3 }
    let(:spell_title) { "Огненный шар" }
    let(:original_title) { "Fireball" }

    it { is_expected.to eq("[3] Огненный шар [Fireball]") }

    context "with a cantrip (level 0)" do
      let(:level) { 0 }

      it { is_expected.to eq("[0] Огненный шар [Fireball]") }
    end

    context "without an original title" do
      let(:original_title) { nil }

      it { is_expected.to eq("[3] Огненный шар") }
    end

    context "without a level" do
      let(:level) { nil }

      it { is_expected.to eq("Огненный шар [Fireball]") }
    end
  end

  describe "#description_for_telegram" do
    subject(:description) { spell.decorate.description_for_telegram }

    let(:spell) { build(:spell, description: raw_description) }
    let(:raw_description) { "**Hello**" }

    it { is_expected.to eq(FormatChanger.markdown_to_telegram_markdown(raw_description).strip) }

    context "when the description is blank" do
      let(:raw_description) { "" }

      it { is_expected.to be_nil }
    end
  end

  describe "#parse_mode_for_telegram" do
    subject(:parse_mode) { spell.decorate.parse_mode_for_telegram }

    let(:spell) { build(:spell) }

    it { is_expected.to eq("HTML") }
  end

  describe "#global_search_title" do
    subject(:global_search_title) { spell.decorate.global_search_title }

    let(:spell) { build(:spell, level: 1, title: "щит", original_title: "Shield") }

    it { is_expected.to eq("[#{Spell.model_name.human}] #{spell.decorate.title.capitalize}") }
  end
end
