RSpec.describe BotCommands::Roll do
  subject { described_class.call(input_value: input_value) }

  let(:expected_roll_grid_answer) do
    {
      parse_mode: "HTML",
      reply_markup: expected_reply_markup,
      text: expected_text
    }
  end
  let(:expected_reply_markup) do
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
  let(:expected_text) do
    <<~TEXT.chomp
      Для мгновенного броска ты можешь вызвать команду с нужными значениями в формате: <blockquote>/roll ХdY+Z</blockquote>
      
      Примеры вызова команды:
      * /roll 2d20
      * /r 2d20
      * /roll 3d4+3
      * /r 1d10-1 4d4+2 5d5 (множественный бросок)
      
      Для броска выбери кость из таблицы:
    TEXT
  end

  context "when roll formula is blank" do
    let(:input_value) { nil }

    it "gives roll grid to choose from" do
      expect(subject).to eq(
        [
          {answer: expected_roll_grid_answer, type: :message}
        ]
      )
    end
  end

  context "when roll formula has all required data" do
    let(:input_value) { "1d1" }

    let(:expected_roll_result) do
      {
        parse_mode: "HTML",
        reply_markup: expected_markup,
        text: "<b>Бросок:</b> 🎲 1d1\n<b>Выпавшие кости:</b> 1\n<b>Результат:</b> 1"
      }
    end
    let(:expected_markup) do
      {inline_keyboard: [[{callback_data: "roll:", text: "Другой бросок"}]]}
    end

    it "rolls the roll" do
      expect(subject).to eq(
        [
          {answer: expected_roll_result, type: :edit}
        ]
      )
    end
  end

  context "when roll formula is invalid" do
    let(:input_value) { "-" }

    let(:invalid_formula_answer) do
      {
        parse_mode: "HTML",
        reply_markup: {},
        text: "Неправильный формат формулы для броска"
      }
    end

    it "does not process the command" do
      expect(subject).to eq(
        [
          {answer: invalid_formula_answer, type: :message}
        ]
      )
    end
  end
end
