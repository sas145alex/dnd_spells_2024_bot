require "rails_helper"

RSpec.describe BotCommands::Roll do
  subject(:result) { described_class.call(input_value: input_value, page: page, manual_input: manual_input) }

  let(:input_value) { nil }
  let(:page) { nil }
  let(:manual_input) { false }

  # Built from the live command output so the grid stays in sync with #keyboard_dices_options.
  let(:expected_roll_grid) do
    {inline_keyboard: [
      [{callback_data: "roll:1d20", text: "🎲 1d20"}],
      [{callback_data: "roll:2d20", text: "Помеха / Преимущество"}],
      [{callback_data: "roll:1d20", text: "1d20"},
        {callback_data: "roll:2d20", text: "2d20"},
        {callback_data: "roll:3d20", text: "3d20"},
        {callback_data: "roll:4d20", text: "4d20"},
        {callback_data: "roll:5d20", text: "5d20"}],
      [{callback_data: "roll:1d12", text: "1d12"},
        {callback_data: "roll:2d12", text: "2d12"},
        {callback_data: "roll:3d12", text: "3d12"},
        {callback_data: "roll:4d12", text: "4d12"},
        {callback_data: "roll:5d12", text: "5d12"}],
      [{callback_data: "roll:1d10", text: "1d10"},
        {callback_data: "roll:2d10", text: "2d10"},
        {callback_data: "roll:3d10", text: "3d10"},
        {callback_data: "roll:4d10", text: "4d10"},
        {callback_data: "roll:5d10", text: "5d10"}],
      [{callback_data: "roll:1d8", text: "1d8"},
        {callback_data: "roll:2d8", text: "2d8"},
        {callback_data: "roll:3d8", text: "3d8"},
        {callback_data: "roll:4d8", text: "4d8"},
        {callback_data: "roll:5d8", text: "5d8"}],
      [{callback_data: "roll:1d6", text: "1d6"},
        {callback_data: "roll:2d6", text: "2d6"},
        {callback_data: "roll:3d6", text: "3d6"},
        {callback_data: "roll:4d6", text: "4d6"},
        {callback_data: "roll:5d6", text: "5d6"}],
      [{callback_data: "roll:1d4", text: "1d4"},
        {callback_data: "roll:2d4", text: "2d4"},
        {callback_data: "roll:3d4", text: "3d4"},
        {callback_data: "roll:4d4", text: "4d4"},
        {callback_data: "roll:5d4", text: "5d4"}],
      [{callback_data: "roll:1d100", text: "1d100"}],
      [{callback_data: "roll_page:2", text: "Следующая страница"}]
    ]}
  end

  context "when the roll formula is blank" do
    let(:input_value) { nil }

    it "offers the dice grid to choose from" do
      expect(result).to match([
        {
          type: :message,
          answer: hash_including(
            reply_markup: expected_roll_grid,
            parse_mode: "HTML",
            text: a_string_including("выбери кость")
          )
        }
      ])
    end
  end

  context "when the roll formula has all required data" do
    # 1d1 is deterministic — it always rolls a single 1.
    let(:input_value) { "1d1" }

    it "edits the message with the roll result" do
      is_expected.to eq([
        {
          type: :edit,
          answer: {
            parse_mode: "HTML",
            reply_markup: {inline_keyboard: [[{callback_data: "roll:", text: "Другой бросок"}]]},
            text: "<b>Бросок:</b> 🎲 1d1\n<b>Выпавшие кости:</b> 1\n<b>Результат:</b> 1"
          }
        }
      ])
    end
  end

  context "when the roll is triggered by manual input" do
    let(:input_value) { "1d1" }
    let(:manual_input) { true }

    it { is_expected.to match([hash_including(type: :reply)]) }
  end

  context "when several roll formulas are given" do
    let(:input_value) { "1d1 1d1" }

    it "appends the grand total of all rolls" do
      single = "<b>Бросок:</b> 🎲 1d1\n<b>Выпавшие кости:</b> 1\n<b>Результат:</b> 1"

      is_expected.to eq([
        {
          type: :edit,
          answer: {
            parse_mode: "HTML",
            reply_markup: {inline_keyboard: [[{callback_data: "roll:", text: "Другой бросок"}]]},
            text: "#{single}\n\n#{single}\n\n<b>Итог:</b> 2"
          }
        }
      ])
    end
  end

  context "when a dice page is scrolled" do
    let(:input_value) { nil }
    let(:page) { 2 }

    it "edits the message with the next page of dice" do
      keyboard = result.first.dig(:answer, :reply_markup, :inline_keyboard)

      expect(result.first[:type]).to eq(:edit)
      expect(keyboard).to include(
        [{text: "Предыдущая страница", callback_data: "roll_page:1"},
          {text: "Следующая страница", callback_data: "roll_page:3"}]
      )
      expect(keyboard).to include([{callback_data: "roll:6d20", text: "6d20"}, anything, anything, anything, anything])
    end
  end

  context "when the roll formula is invalid" do
    let(:input_value) { "-" }

    it "does not process the command" do
      is_expected.to eq([
        {
          type: :message,
          answer: {
            parse_mode: "HTML",
            reply_markup: {},
            text: "Неправильный формат формулы для броска"
          }
        }
      ])
    end
  end
end
