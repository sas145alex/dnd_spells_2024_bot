require "rails_helper"

RSpec.describe BotCommands::Sections do
  describe "#call" do
    subject(:result) { described_class.call(input_value: input_value, response_type: response_type) }

    let(:input_value) { nil }
    let(:response_type) { :message }

    let(:expected_keyboard) do
      [
        [{text: "Заклинания", callback_data: "all_spells:"}],
        [{text: "Классы", callback_data: "class:"}],
        [{text: "Черты", callback_data: "feat:"}],
        [{text: "Виды и расы", callback_data: "species:"}],
        [{text: "Происхождения", callback_data: "origin:"}],
        [{text: "Инструменты", callback_data: "tool:"}],
        [{text: "Снаряжение", callback_data: "equipment:"}],
        [{text: "Бастионы", callback_data: "bastion:"}],
        [{text: "Глоссарий", callback_data: "glossary:"}]
      ]
    end

    context "with default response type" do
      it "returns a single message hash with all sections" do
        expect(result).to eq(
          [
            {
              type: :message,
              answer: {
                text: "Выбери интересующий раздел\n",
                reply_markup: {inline_keyboard: expected_keyboard},
                parse_mode: "HTML"
              }
            }
          ]
        )
      end
    end

    context "when an edit response type is requested" do
      let(:response_type) { :edit }

      it "wraps the answer in an :edit message" do
        expect(result.first[:type]).to eq(:edit)
      end
    end
  end
end
