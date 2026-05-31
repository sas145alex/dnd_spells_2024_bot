require "rails_helper"

RSpec.describe BotCommands::SpeciesSearch do
  subject(:result) { described_class.call(input_value: input_value) }

  let(:input_value) { nil }

  context "when the input is blank" do
    let(:input_value) { nil }
    let!(:race) { create(:race, title: "Эльф", description: "an elf", published_at: Time.current) }

    it "renders the list of races/species" do
      expect(result).to eq(
        text: "Выбери расу/вид:",
        reply_markup: {
          inline_keyboard: [
            [{text: race.decorate.title, callback_data: "species:#{race.to_global_id}"}],
            [{text: "Назад", callback_data: "go_back:go_back"}]
          ]
        },
        parse_mode: "HTML"
      )
    end
  end

  context "when a race is selected by global id" do
    let(:race) { create(:race, title: "Эльф", description: "an elf", published_at: Time.current) }
    let(:input_value) { race.to_global_id.to_s }

    it "renders the race details" do
      expect(result).to eq(
        text: <<~HTML,
          <b>#{race.decorate.title}</b>

          #{race.decorate.description_for_telegram}
        HTML
        reply_markup: {inline_keyboard: [[{text: "Назад", callback_data: "go_back:go_back"}]]},
        parse_mode: "HTML"
      )
    end
  end

  context "when the input does not resolve to a race" do
    let(:input_value) { "not-a-gid" }

    it { is_expected.to eq(text: "Невалидный ввод", reply_markup: {}, parse_mode: "HTML") }
  end
end
