require "rails_helper"

RSpec.describe BotCommands::EquipmentSearch do
  subject(:result) { described_class.call(input_value: input_value) }

  let(:input_value) { nil }

  context "when the input is blank" do
    let(:input_value) { nil }

    it "renders the fixed top-level categories" do
      options = described_class::TOP_LEVEL_CATEGORIES.map do |key, translation|
        {text: translation, callback_data: "equipment:#{key}"}
      end

      expect(result).to eq(
        text: "Выбери категорию",
        reply_markup: {
          inline_keyboard: options.in_groups_of(2, false) + [[{text: "Назад", callback_data: "go_back:go_back"}]]
        },
        parse_mode: "HTML"
      )
    end
  end

  context "when a top-level category is selected" do
    let(:input_value) { "weapon" }

    it "renders the weapon subcategories" do
      options = EquipmentItem.human_enum_names(:item_type, only: EquipmentItem.weapon_item_types).map do |translation, key|
        {text: translation, callback_data: "equipment:#{key}"}
      end

      expect(result).to eq(
        text: "Выбери подкатегорию",
        reply_markup: {
          inline_keyboard: options.in_groups_of(2, false) + [[{text: "Назад", callback_data: "go_back:go_back"}]]
        },
        parse_mode: "HTML"
      )
    end
  end

  context "when a subcategory is selected" do
    let(:input_value) { "simple_melee" }
    let!(:item) do
      create(:equipment_item, title: "Zтест экип", description: "d" * 20, item_type: "simple_melee", published_at: Time.current)
    end

    it "lists the equipment items of the subcategory" do
      expect(result).to eq(
        text: "Выбери предмет",
        reply_markup: {
          inline_keyboard: [
            [{text: item.decorate.title, callback_data: "equipment:#{item.to_global_id}"}],
            [{text: "Назад", callback_data: "go_back:go_back"}]
          ]
        },
        parse_mode: "HTML"
      )
    end
  end

  context "when an equipment item is selected by global id" do
    let(:item) do
      create(:equipment_item, title: "Zтест экип", description: "d" * 20, item_type: "simple_melee", published_at: Time.current)
    end
    let(:input_value) { item.to_global_id.to_s }

    it "renders the equipment item details" do
      expect(result).to eq(
        text: item.decorate.description_for_telegram,
        reply_markup: {inline_keyboard: [[{text: "Назад", callback_data: "go_back:go_back"}]]},
        parse_mode: "HTML"
      )
    end
  end

  context "when the input does not resolve to anything" do
    let(:input_value) { "not-a-gid" }

    it { is_expected.to eq(text: "Невалидный ввод", reply_markup: {}, parse_mode: "HTML") }
  end
end
