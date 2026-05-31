require "rails_helper"

RSpec.describe WildMagicDecorator do
  describe "#title" do
    subject(:title) { wild_magic.decorate.title }

    let(:wild_magic) { build(:wild_magic, roll: roll) }
    let(:roll) { 1..4 }

    it { is_expected.to eq("Дикая магия (1..4)") }

    context "with a different roll range" do
      let(:roll) { 50..55 }

      it { is_expected.to eq("Дикая магия (50..55)") }
    end

    context "without a roll" do
      let(:roll) { nil }

      it { is_expected.to eq("") }
    end
  end

  describe "#description_for_telegram" do
    subject(:description) { wild_magic.decorate.description_for_telegram }

    let(:wild_magic) { build(:wild_magic, roll: 1..4, description: raw_description) }
    let(:raw_description) { "**Сюрприз**" }

    it "renders the title heading followed by the markdown description" do
      expected = "<b>#{wild_magic.decorate.title}</b>\n\n" \
        "#{FormatChanger.markdown_to_telegram_markdown(raw_description)}".strip

      expect(description).to eq(expected)
    end
  end

  describe "#global_search_title" do
    subject(:global_search_title) { wild_magic.decorate.global_search_title }

    let(:wild_magic) { build(:wild_magic, roll: 1..4) }

    it { is_expected.to eq("[#{WildMagic.model_name.human}] #{wild_magic.decorate.title.capitalize}") }
  end

  describe "#parse_mode_for_telegram" do
    subject(:parse_mode) { wild_magic.decorate.parse_mode_for_telegram }

    let(:wild_magic) { build(:wild_magic) }

    it { is_expected.to eq("HTML") }
  end
end
