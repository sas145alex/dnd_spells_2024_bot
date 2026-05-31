require "rails_helper"

RSpec.describe BotCommands::InvocationsSearch do
  subject(:result) { described_class.call(input_value: input_value) }

  let(:input_value) { nil }

  context "when the input is blank" do
    let(:input_value) { nil }
    let!(:invocation) do
      create(:invocation, title: "Демонический взгляд", description: "d", published_at: Time.current)
    end

    it "renders the list of invocations" do
      expect(result).to eq(
        text: "Выбери",
        reply_markup: {
          inline_keyboard: [
            [{text: invocation.decorate.title, callback_data: "invocations:#{invocation.decorate.to_global_id}"}],
            [{text: "Назад", callback_data: "go_back:go_back"}]
          ]
        },
        parse_mode: "HTML"
      )
    end
  end

  context "when an invocation is selected by global id" do
    let(:invocation) do
      create(:invocation, title: "Демонический взгляд", description: "boom", published_at: Time.current)
    end
    let(:input_value) { invocation.decorate.to_global_id.to_s }

    it "renders the invocation description" do
      expect(result).to eq(
        text: invocation.decorate.description_for_telegram,
        reply_markup: {inline_keyboard: [[{text: "Назад", callback_data: "go_back:go_back"}]]},
        parse_mode: "HTML"
      )
    end
  end

  context "when the input does not resolve to an invocation" do
    let(:input_value) { "not-a-gid" }

    it { is_expected.to eq(text: "Невалидный ввод", reply_markup: {}, parse_mode: "HTML") }
  end
end
