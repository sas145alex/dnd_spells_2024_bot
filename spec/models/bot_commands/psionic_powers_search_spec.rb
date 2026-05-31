require "rails_helper"

RSpec.describe BotCommands::PsionicPowersSearch do
  subject(:result) { described_class.call(input_value: input_value) }

  let(:input_value) { nil }

  context "when the input is blank" do
    let(:input_value) { nil }
    let!(:psionic_power) do
      create(:psionic_power, title: "Психический клинок", description: "d", published_at: Time.current)
    end

    it "renders the list of psionic powers" do
      expect(result).to eq(
        text: "Выбери",
        reply_markup: {
          inline_keyboard: [
            [{text: psionic_power.decorate.title, callback_data: "psionic_powers:#{psionic_power.decorate.to_global_id}"}],
            [{text: "Назад", callback_data: "go_back:go_back"}]
          ]
        },
        parse_mode: "HTML"
      )
    end
  end

  context "when a psionic power is selected by global id" do
    let(:psionic_power) do
      create(:psionic_power, title: "Психический клинок", description: "boom", published_at: Time.current)
    end
    let(:input_value) { psionic_power.decorate.to_global_id.to_s }

    it "renders the psionic power description" do
      expect(result).to eq(
        text: psionic_power.decorate.description_for_telegram,
        reply_markup: {inline_keyboard: [[{text: "Назад", callback_data: "go_back:go_back"}]]},
        parse_mode: "HTML"
      )
    end
  end

  context "when the input does not resolve to a psionic power" do
    let(:input_value) { "not-a-gid" }

    it { is_expected.to eq(text: "Невалидный ввод", reply_markup: {}, parse_mode: "HTML") }
  end
end
