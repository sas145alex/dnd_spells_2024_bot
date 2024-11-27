RSpec.describe BotCommands::WildMagicSearch do
  subject(:fetch) { described_class.call(input_value: input_value) }

  let(:input_value) { nil }

  let!(:random_wild_magic) { create(:wild_magic, roll: 0..100, description: "random roll") }

  context "when specify some roll" do
    let(:input_value) { "101" }

    let!(:specified_wild_magic) { create(:wild_magic, roll: 101..102, description: "description 100") }

    it "fetches proper wild magic" do
      expect(fetch).to eq({
        text: specified_wild_magic.decorate.description_for_telegram,
        reply_markup: {inline_keyboard: []},
        parse_mode: "HTML"
      })
    end

    context "when specified input is invalid" do
      let(:input_value) { "invalid" }

      it "fetches random wild magic" do
        expect(fetch).to eq({
          text: random_wild_magic.decorate.description_for_telegram,
          reply_markup: {inline_keyboard: []},
          parse_mode: "HTML"
        })
      end
    end
  end

  it "fetches random wild magic" do
    expect(fetch).to eq({
      text: random_wild_magic.decorate.description_for_telegram,
      reply_markup: {inline_keyboard: []},
      parse_mode: "HTML"
    })
  end
end
