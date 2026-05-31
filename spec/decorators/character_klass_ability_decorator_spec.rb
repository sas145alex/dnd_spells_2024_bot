require "rails_helper"

RSpec.describe CharacterKlassAbilityDecorator do
  describe "#title" do
    subject(:title) { ability.decorate.title }

    let(:ability) { build(:character_klass_ability, title: "Второе дыхание", character_klass: character_klass) }

    context "when the ability belongs to a base klass" do
      let(:character_klass) { build(:character_klass, title: "Воин") }

      it { is_expected.to eq("Второе дыхание") }
    end

    context "when the ability belongs to a subklass" do
      let(:parent_klass) { create(:character_klass, title: "Воин") }
      let(:character_klass) { build(:character_klass, title: "Чемпион", parent_klass: parent_klass) }

      it { is_expected.to eq("#{CharacterKlassAbilityDecorator::EMOJI} Второе дыхание") }
    end
  end

  describe "#description_for_telegram" do
    subject(:description) { ability.decorate.description_for_telegram }

    let(:ability) { build(:character_klass_ability, description: raw_description) }
    let(:raw_description) { "**Hello**" }

    it { is_expected.to eq(FormatChanger.markdown_to_telegram_markdown(raw_description).strip) }

    context "when the description is blank" do
      let(:raw_description) { "" }

      it { is_expected.to be_nil }
    end
  end

  describe "#global_search_title" do
    subject(:global_search_title) { ability.decorate.global_search_title }

    let(:character_klass) { build(:character_klass, title: "Воин") }
    let(:ability) { build(:character_klass_ability, title: "второе дыхание", character_klass: character_klass) }

    it do
      expect(global_search_title)
        .to eq("[#{CharacterKlassAbility.model_name.human}] #{ability.decorate.title.capitalize}")
    end
  end

  describe "#parse_mode_for_telegram" do
    subject(:parse_mode) { ability.decorate.parse_mode_for_telegram }

    let(:ability) { build(:character_klass_ability) }

    it { is_expected.to eq("HTML") }
  end
end
