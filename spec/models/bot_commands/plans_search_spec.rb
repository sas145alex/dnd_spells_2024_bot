require "rails_helper"

RSpec.describe BotCommands::PlansSearch do
  subject(:result) { described_class.call(input_value: input_value) }

  let(:input_value) { nil }

  context "when the input is blank" do
    let(:input_value) { nil }
    let!(:plan) { create(:plan, :published, title: "Стихийный план Огня") }

    it "renders the list of plans" do
      expect(result).to eq(
        text: "Выбери",
        reply_markup: {
          inline_keyboard: [
            [{text: plan.decorate.title, callback_data: "plans:#{plan.decorate.to_global_id}"}],
            [{text: "Назад", callback_data: "go_back:go_back"}]
          ]
        },
        parse_mode: "HTML"
      )
    end
  end

  context "when a plan is selected by global id" do
    let(:plan) { create(:plan, :published, title: "Стихийный план Огня", description: "hot") }
    let(:input_value) { plan.decorate.to_global_id.to_s }

    it "renders the plan description" do
      expect(result).to eq(
        text: plan.decorate.description_for_telegram,
        reply_markup: {inline_keyboard: [[{text: "Назад", callback_data: "go_back:go_back"}]]},
        parse_mode: "HTML"
      )
    end
  end

  context "when the input does not resolve to a plan" do
    let(:input_value) { "not-a-gid" }

    it { is_expected.to eq(text: "Невалидный ввод", reply_markup: {}, parse_mode: "HTML") }
  end
end
