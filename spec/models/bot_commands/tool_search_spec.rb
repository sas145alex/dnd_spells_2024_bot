require "rails_helper"

RSpec.describe BotCommands::ToolSearch do
  subject(:result) { described_class.call(input_value: input_value) }

  let(:input_value) { nil }

  context "when the input is blank" do
    let(:input_value) { nil }

    it "renders the top-level category enum options" do
      enum_options = Tool.human_enum_names(:category, locale: "ru").map do |translation, raw|
        {text: translation, callback_data: "tool:#{raw}"}
      end

      expect(result).to eq(
        text: "Выбери категорию",
        reply_markup: {
          inline_keyboard: enum_options.in_groups_of(2, false) + [[{text: "Назад", callback_data: "go_back:go_back"}]]
        },
        parse_mode: "HTML"
      )
    end
  end

  context "when a category is selected" do
    let(:category) { Tool.categories.keys.first }
    let!(:tool) { create(:tool, title: "Zтест тул", description: "d" * 20, category: category, published_at: Time.current) }
    let(:input_value) { category }

    it "lists the tools of the category prefixed with info options" do
      expect(result).to eq(
        text: "Выбери набор инстументов",
        reply_markup: {
          inline_keyboard: [
            [{
              text: BotCommand.crafting.decorate.title,
              callback_data: "tool:#{BotCommand.crafting.decorate.to_global_id}"
            }],
            [{
              text: BotCommand.tool.decorate.title,
              callback_data: "tool:#{BotCommand.tool.decorate.to_global_id}"
            }],
            [{text: tool.decorate.title, callback_data: "tool:#{tool.to_global_id}"}],
            [{text: "Назад", callback_data: "go_back:go_back"}]
          ]
        },
        parse_mode: "HTML"
      )
    end
  end

  context "when a tool is selected by global id" do
    let(:tool) { create(:tool, title: "Zтест тул", description: "d" * 20, published_at: Time.current) }
    let(:input_value) { tool.to_global_id.to_s }

    it "renders the tool details" do
      expect(result).to eq(
        text: tool.decorate.description_for_telegram,
        reply_markup: {inline_keyboard: [[{text: "Назад", callback_data: "go_back:go_back"}]]},
        parse_mode: "HTML"
      )
    end
  end

  context "when the info bot command is selected" do
    let(:input_value) { BotCommand.tool.decorate.to_global_id.to_s }

    it "renders the general info of the section" do
      expect(result).to eq(
        text: BotCommand.tool.decorate.description_for_telegram,
        reply_markup: {inline_keyboard: [[{text: "Назад", callback_data: "go_back:go_back"}]]},
        parse_mode: "HTML"
      )
    end
  end

  context "when the input does not resolve to anything" do
    let(:input_value) { "not-a-gid" }

    it { is_expected.to eq(text: "Невалидный ввод", reply_markup: {}, parse_mode: "HTML") }
  end
end
