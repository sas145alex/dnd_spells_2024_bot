RSpec.describe BotCommands::Roll do
  subject { described_class.call(roll_formula: roll_formula) }

  context "when roll formula is blank" do
    let(:roll_formula) { nil }

    it "asc user of dice count" do
      expect(subject).to match(
        {
          text: "Выберете количество костей:",
          parse_mode: "HTML",
          reply_markup: {
            inline_keyboard: instance_of(Array)
          }
        }
      )
    end

    it "shows keyboard with some options" do
      expect(subject[:reply_markup][:inline_keyboard].size).not_to eq(0)
    end
  end

  context "when roll formula consist of only dice count" do
    let(:roll_formula) { "4" }

    it "asc user of dice value" do
      expect(subject).to match(
        {
          text: "<b>Количество костей: 4</b>\n\nВыбери номинал костей:",
          parse_mode: "HTML",
          reply_markup: {
            inline_keyboard: instance_of(Array)
          }
        }
      )
    end

    it "shows keyboard with some options" do
      expect(subject[:reply_markup][:inline_keyboard].size).not_to eq(0)
    end
  end

  context "when roll formula has all required data" do
    let(:roll_formula) { "1d1" }

    it "rolls the roll" do
      expect(subject).to match(
        {
          text: "<b>Бросок:</b> 1d1\n<b>Все результаты:</b> 1\n<b>Сумма:</b> 1\n",
          parse_mode: "HTML",
          reply_markup: {}
        }
      )
    end

    it "does not shows keyboard" do
      expect(subject[:reply_markup].key?(:inline_keyboard)).to eq(false)
    end
  end

  context "when roll formula is invalid" do
    let(:roll_formula) { "-" }

    it "does not process the command" do
      expect(subject).to match(
        {
          text: "Неправильный формат формулы для броска",
          parse_mode: "HTML",
          reply_markup: {}
        }
      )
    end

    it "does not shows keyboard" do
      expect(subject[:reply_markup].key?(:inline_keyboard)).to eq(false)
    end
  end
end
