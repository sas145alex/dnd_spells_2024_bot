require "rails_helper"

RSpec.describe BotCommands::ArcaneShotsSearch do
  subject(:result) { described_class.call(input_value: input_value) }

  let(:input_value) { nil }

  context "when the input is blank" do
    let(:input_value) { nil }
    let!(:arcane_shot) { create(:arcane_shot, :published, title: "Громовой выстрел") }

    it "renders the list of arcane shots" do
      expect(result).to eq(
        text: "Выбери",
        reply_markup: {
          inline_keyboard: [
            [{text: arcane_shot.decorate.title, callback_data: "arcane_shots:#{arcane_shot.decorate.to_global_id}"}],
            [{text: "Назад", callback_data: "go_back:go_back"}]
          ]
        },
        parse_mode: "HTML"
      )
    end
  end

  context "when an arcane shot is selected by global id" do
    let(:arcane_shot) { create(:arcane_shot, :published, title: "Громовой выстрел", description: "boom") }
    let(:input_value) { arcane_shot.decorate.to_global_id.to_s }

    it "renders the arcane shot description" do
      expect(result).to eq(
        text: arcane_shot.decorate.description_for_telegram,
        reply_markup: {inline_keyboard: [[{text: "Назад", callback_data: "go_back:go_back"}]]},
        parse_mode: "HTML"
      )
    end
  end

  context "when the input does not resolve to an arcane shot" do
    let(:input_value) { "not-a-gid" }

    it { is_expected.to eq(text: "Невалидный ввод", reply_markup: {}, parse_mode: "HTML") }
  end
end
