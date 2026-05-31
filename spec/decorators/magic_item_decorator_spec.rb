require "rails_helper"

RSpec.describe MagicItemDecorator do
  describe "#title" do
    subject(:title) { magic_item.decorate.title }

    let(:magic_item) { build(:magic_item, title: "Сумка хранения") }

    it { is_expected.to eq("Сумка хранения") }
  end

  describe "#description_for_telegram" do
    subject(:description) { magic_item.decorate.description_for_telegram }

    let(:magic_item) do
      build(
        :magic_item,
        title: "Сумка хранения",
        original_title: "Bag of Holding",
        category: :magic_item,
        rarity: :common,
        attunement: :unrequired,
        charges: false,
        cursed: false,
        price: "500 зм",
        description: raw_description
      )
    end
    let(:raw_description) { "**Полезный предмет**" }

    it "renders the structured HTML block followed by the markdown description" do
      expected = "<b>Сумка хранения</b>\n\n" \
        "<b>Оригинальное название</b> Bag of Holding\n" \
        "<b>Категория</b> #{magic_item.human_enum_name(:category)}\n" \
        "<b>Редкость</b> #{magic_item.human_enum_name(:rarity)}\n" \
        "<b>Настройка</b> #{magic_item.human_enum_name(:attunement)}\n" \
        "<b>Имеет заряды</b> #{I18n.t(false)}\n" \
        "<b>Проклято</b> #{I18n.t(false)}\n" \
        "<b>Цена</b> 500 зм\n\n" \
        "#{FormatChanger.markdown_to_telegram_markdown(raw_description)}".strip

      expect(description).to eq(expected)
    end
  end

  describe "#global_search_title" do
    subject(:global_search_title) { magic_item.decorate.global_search_title }

    let(:magic_item) { build(:magic_item, title: "сумка хранения") }

    it { is_expected.to eq("[#{MagicItem.model_name.human}] #{magic_item.decorate.title.capitalize}") }
  end

  describe "#parse_mode_for_telegram" do
    subject(:parse_mode) { magic_item.decorate.parse_mode_for_telegram }

    let(:magic_item) { build(:magic_item) }

    it { is_expected.to eq("HTML") }
  end
end
