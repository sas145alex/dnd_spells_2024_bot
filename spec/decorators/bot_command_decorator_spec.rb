require "rails_helper"

RSpec.describe BotCommandDecorator do
  describe "#title" do
    subject(:title) { bot_command.decorate.title }

    let(:bot_command) { build(:bot_command, title: command_title) }

    context "with an ordinary command title" do
      let(:command_title) { "start" }

      it { is_expected.to eq("start") }
    end

    context "with the tool command" do
      let(:command_title) { BotCommand::TOOL_ID }

      it { is_expected.to eq("Подробнее об инструментах") }
    end

    context "with the crafting command" do
      let(:command_title) { BotCommand::CRAFTING_ID }

      it { is_expected.to eq("Подробнее о системе создания предметов") }
    end

    context "with the origin command" do
      let(:command_title) { BotCommand::ORIGIN_ID }

      it { is_expected.to eq("Подробнее о происхождениях") }
    end
  end

  describe "#description_for_telegram" do
    subject(:description) { bot_command.decorate.description_for_telegram }

    let(:bot_command) { build(:bot_command, title: "start", description: raw_description) }
    let(:raw_description) { "**Hello**" }

    it { is_expected.to eq(FormatChanger.markdown_to_telegram_markdown(raw_description).strip) }

    context "when the description is blank" do
      let(:raw_description) { "" }

      it { is_expected.to be_nil }
    end
  end

  describe "#global_search_title" do
    subject(:global_search_title) { bot_command.decorate.global_search_title }

    let(:bot_command) { build(:bot_command, title: "start") }

    it { is_expected.to eq("[#{BotCommand.model_name.human}] #{bot_command.decorate.title.capitalize}") }
  end

  describe "#parse_mode_for_telegram" do
    subject(:parse_mode) { bot_command.decorate.parse_mode_for_telegram }

    let(:bot_command) { build(:bot_command, title: "start") }

    it { is_expected.to eq("HTML") }
  end
end
