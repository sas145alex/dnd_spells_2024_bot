require "rails_helper"

RSpec.describe BotCommands::ManeuversSearch do
  subject(:result) { described_class.call(input_value: input_value) }

  let(:input_value) { nil }

  context "when the input is blank" do
    let(:input_value) { nil }
    let!(:maneuver) do
      create(:maneuver, title: "Атака с разбегу", description: "d", published_at: Time.current)
    end

    it "renders the list of maneuvers" do
      expect(result).to eq(
        text: "Выбери",
        reply_markup: {
          inline_keyboard: [
            [{text: maneuver.decorate.title, callback_data: "maneuvers:#{maneuver.decorate.to_global_id}"}],
            [{text: "Назад", callback_data: "go_back:go_back"}]
          ]
        },
        parse_mode: "HTML"
      )
    end
  end

  context "when a maneuver is selected by global id" do
    let(:maneuver) do
      create(:maneuver, title: "Атака с разбегу", description: "boom", published_at: Time.current)
    end
    let(:input_value) { maneuver.decorate.to_global_id.to_s }

    it "renders the maneuver description" do
      expect(result).to eq(
        text: maneuver.decorate.description_for_telegram,
        reply_markup: {inline_keyboard: [[{text: "Назад", callback_data: "go_back:go_back"}]]},
        parse_mode: "HTML"
      )
    end
  end

  context "when the input does not resolve to a maneuver" do
    let(:input_value) { "not-a-gid" }

    it { is_expected.to eq(text: "Невалидный ввод", reply_markup: {}, parse_mode: "HTML") }
  end
end
