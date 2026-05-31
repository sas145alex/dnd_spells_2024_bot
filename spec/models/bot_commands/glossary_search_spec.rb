require "rails_helper"

RSpec.describe BotCommands::GlossarySearch do
  subject(:result) { described_class.call(input_value: input_value) }

  let(:input_value) { nil }

  context "when the input is blank" do
    let(:input_value) { nil }
    let!(:category) { create(:glossary_category, title: "Состояния") }

    it "renders the top-level categories" do
      expect(result).to eq(
        text: "Выбери категорию:",
        reply_markup: {
          inline_keyboard: [
            [{text: category.decorate.title, callback_data: "glossary:#{category.to_global_id}"}],
            [{text: "Назад", callback_data: "go_back:go_back"}]
          ]
        },
        parse_mode: "HTML"
      )
    end
  end

  context "when a category with items is selected" do
    let(:category) { create(:glossary_category, title: "Состояния") }
    let!(:item) { create(:glossary_item, title: "Отравление", category: category) }
    let(:input_value) { category.to_global_id.to_s }

    it "renders the category items" do
      expect(result).to eq(
        text: <<~HTML,
          "#{""}"
          <b>Категория:</b> #{category.title}
          <b>Всего терминов:</b> #{category.items.count}

          Выберите термин:
        HTML
        reply_markup: {
          inline_keyboard: [
            [{text: item.title, callback_data: "glossary:#{item.to_global_id}"}],
            [{text: "Назад", callback_data: "go_back:go_back"}]
          ]
        },
        parse_mode: "HTML"
      )
    end
  end

  context "when a category without items is selected" do
    let(:category) { create(:glossary_category, title: "Состояния") }
    let!(:subcategory) { create(:glossary_category, title: "Болезни", parent_category: category) }
    let(:input_value) { category.to_global_id.to_s }

    it "renders the subcategories" do
      expect(result).to eq(
        text: <<~HTML,
          <b>Категория:</b> #{category.title}
          <b>Всего подкатегорий:</b> #{category.subcategories.count}

          Выбери категорию:
        HTML
        reply_markup: {
          inline_keyboard: [
            [{text: subcategory.decorate.title, callback_data: "glossary:#{subcategory.to_global_id}"}],
            [{text: "Назад", callback_data: "go_back:go_back"}]
          ]
        },
        parse_mode: "HTML"
      )
    end
  end

  context "when a glossary item is selected" do
    let(:item) { create(:glossary_item, title: "Отравление", description: "poisoned") }
    let(:input_value) { item.to_global_id.to_s }

    it "renders the glossary item details" do
      expect(result).to eq(
        text: <<~HTML,
          <b>#{item.decorate.title}</b>

          #{item.decorate.description_for_telegram}
        HTML
        reply_markup: {inline_keyboard: [[{text: "Назад", callback_data: "go_back:go_back"}]]},
        parse_mode: "HTML"
      )
    end
  end

  context "when the input does not resolve to a glossary record" do
    let(:input_value) { "not-a-gid" }

    it { is_expected.to eq(text: "Невалидный ввод", reply_markup: {}, parse_mode: "HTML") }
  end
end
