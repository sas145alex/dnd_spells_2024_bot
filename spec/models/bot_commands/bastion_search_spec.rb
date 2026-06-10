require "rails_helper"

RSpec.describe BotCommands::BastionSearch do
  subject(:fetch) { described_class.call(input_value: input_value) }

  let(:input_value) { nil }

  let(:go_back) { {text: "Назад", callback_data: "go_back:go_back"} }

  let!(:bedroom) { create(:bastion, :published, category: :construction, title: "Спальня") }
  let!(:walls) { create(:bastion, :published, :modification, title: "Защитные стены") }
  let!(:armory) { create(:bastion, :published, :leveling, level: 5, title: "Арсенал") }
  let!(:gaming_hall) { create(:bastion, :published, :leveling, level: 9, title: "Игорное заведение") }

  context "without input (top categories)" do
    it "lists Базовые and Специализированные" do
      expect(fetch[:text]).to eq("Выбери категорию")
      expect(fetch[:reply_markup][:inline_keyboard]).to eq([
        [{text: "Базовые сооружения", callback_data: "bastion:basic"}],
        [{text: "Специализированные", callback_data: "bastion:specialized"}],
        [go_back]
      ])
    end
  end

  context "when the basic group is selected" do
    let(:input_value) { "basic" }

    it "offers Строительство alongside the Постройки and Модификации lists" do
      expect(fetch[:reply_markup][:inline_keyboard]).to eq([
        [{text: "Строительство", callback_data: "bastion:building"}],
        [
          {text: "Постройки", callback_data: "bastion:construction"},
          {text: "Модификации", callback_data: "bastion:modification"}
        ],
        [go_back]
      ])
    end
  end

  context "when the specialized group is selected" do
    let(:input_value) { "specialized" }

    it "offers Получение alongside a button per available level" do
      expect(fetch[:reply_markup][:inline_keyboard]).to eq([
        [{text: "Получение", callback_data: "bastion:obtaining"}],
        [
          {text: "5 уровень", callback_data: "bastion:level_5"},
          {text: "9 уровень", callback_data: "bastion:level_9"}
        ],
        [go_back]
      ])
    end
  end

  context "when Строительство is selected" do
    let(:input_value) { "building" }

    it "renders the building text card" do
      expect(fetch[:text]).to eq(BotCommand.bastion_building.decorate.description_for_telegram)
      expect(fetch[:reply_markup][:inline_keyboard]).to eq([[go_back]])
    end
  end

  context "when Получение is selected" do
    let(:input_value) { "obtaining" }

    it "renders the obtaining text card" do
      expect(fetch[:text]).to eq(BotCommand.bastion_obtaining.decorate.description_for_telegram)
      expect(fetch[:reply_markup][:inline_keyboard]).to eq([[go_back]])
    end
  end

  context "when a basic type is selected" do
    let(:input_value) { "construction" }

    it "lists the construction bastions" do
      expect(fetch[:reply_markup][:inline_keyboard]).to eq([
        [{text: bedroom.title, callback_data: "bastion:#{bedroom.to_global_id}"}],
        [go_back]
      ])
    end
  end

  context "when a level is selected" do
    let(:input_value) { "level_5" }

    it "lists the leveling bastions for that level" do
      expect(fetch[:reply_markup][:inline_keyboard]).to eq([
        [{text: armory.title, callback_data: "bastion:#{armory.to_global_id}"}],
        [go_back]
      ])
    end
  end

  context "when a bastion is selected" do
    let(:input_value) { bedroom.to_global_id.to_s }

    it "renders the decorator card" do
      expect(fetch[:text]).to eq(bedroom.decorate.description_for_telegram)
      expect(fetch[:reply_markup][:inline_keyboard]).to eq([[go_back]])
    end
  end
end
