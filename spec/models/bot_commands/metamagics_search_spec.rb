require "rails_helper"

RSpec.describe BotCommands::MetamagicsSearch do
  subject(:result) { described_class.call(input_value: input_value) }

  let(:input_value) { nil }

  context "when the input is blank" do
    let(:input_value) { nil }
    let!(:metamagic) do
      create(:metamagic, title: "Осторожное заклинание", description: "d", published_at: Time.current)
    end

    it "renders the list of metamagics" do
      expect(result).to eq(
        text: "Выбери",
        reply_markup: {
          inline_keyboard: [
            [{text: metamagic.decorate.title, callback_data: "metamagics:#{metamagic.decorate.to_global_id}"}],
            [{text: "Назад", callback_data: "go_back:go_back"}]
          ]
        },
        parse_mode: "HTML"
      )
    end
  end

  context "when a metamagic is selected by global id" do
    let(:metamagic) do
      create(:metamagic, title: "Осторожное заклинание", description: "boom", published_at: Time.current)
    end
    let(:input_value) { metamagic.decorate.to_global_id.to_s }

    it "renders the metamagic description" do
      expect(result).to eq(
        text: metamagic.decorate.description_for_telegram,
        reply_markup: {inline_keyboard: [[{text: "Назад", callback_data: "go_back:go_back"}]]},
        parse_mode: "HTML"
      )
    end
  end

  context "when the input does not resolve to a metamagic" do
    let(:input_value) { "not-a-gid" }

    it { is_expected.to eq(text: "Невалидный ввод", reply_markup: {}, parse_mode: "HTML") }
  end
end
