require "rails_helper"

RSpec.describe CreatureDecorator do
  describe "#title" do
    subject(:title) { creature.decorate.title }

    let(:creature) { build(:creature, title: creature_title, original_title: original_title) }
    let(:creature_title) { "Гоблин" }
    let(:original_title) { "Goblin" }

    it { is_expected.to eq("Гоблин [Goblin]") }

    context "without an original title" do
      let(:original_title) { nil }

      it { is_expected.to eq("Гоблин") }
    end

    context "without a title" do
      let(:creature_title) { "" }

      it { is_expected.to eq(" [Goblin]") }
    end
  end

  describe "#description_for_telegram" do
    subject(:description) { creature.decorate.description_for_telegram }

    let(:creature) { build(:creature, description: raw_description) }
    let(:raw_description) { "**Hello**" }

    it { is_expected.to eq(FormatChanger.markdown_to_telegram_markdown(raw_description).strip) }

    context "when the description is blank" do
      let(:raw_description) { "" }

      it { is_expected.to be_nil }
    end
  end

  describe "#global_search_title" do
    subject(:global_search_title) { creature.decorate.global_search_title }

    let(:creature) { build(:creature, title: "гоблин", original_title: "Goblin") }

    it "uses the raw object title rather than the decorated one" do
      expect(global_search_title).to eq("[#{Creature.model_name.human}] #{creature.title.capitalize}")
    end
  end

  describe "#admin_mention_title" do
    subject(:admin_mention_title) { creature.decorate.admin_mention_title }

    let(:creature) { build(:creature, title: "Гоблин", original_title: "Goblin", edition_source: "MM25") }

    it { is_expected.to eq("[MM25] Гоблин [Goblin]") }
  end

  describe "#parse_mode_for_telegram" do
    subject(:parse_mode) { creature.decorate.parse_mode_for_telegram }

    let(:creature) { build(:creature) }

    it { is_expected.to eq("HTML") }
  end
end
