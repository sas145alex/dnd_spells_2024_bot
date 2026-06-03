require "rails_helper"

RSpec.describe BotCommands::OriginSearch do
  subject(:result) { described_class.call(input_value: input_value) }

  let(:input_value) { nil }

  context "when the input is blank" do
    let(:input_value) { nil }
    let!(:origin) { create(:origin, title: "Артист", description: "an entertainer", published_at: Time.current) }

    it "renders the origins list with section-info and characteristic-search options" do
      expect(result).to eq(
        text: "Выбери происхождение",
        reply_markup: {
          inline_keyboard: [
            [{
              text: BotCommand.origin.decorate.title,
              callback_data: "origin:#{BotCommand.origin.decorate.to_global_id}"
            }],
            [{text: "Поиск по хар-ке", callback_data: "origin:search_by_characteristic"}],
            [{text: origin.decorate.title, callback_data: "origin:#{origin.to_global_id}"}],
            [{text: "Назад", callback_data: "go_back:go_back"}]
          ]
        },
        parse_mode: "HTML"
      )
    end
  end

  context "when an origin is selected by global id" do
    let(:origin) { create(:origin, title: "Артист", description: "an entertainer", published_at: Time.current) }
    let(:input_value) { origin.to_global_id.to_s }

    it "renders the origin details" do
      expect(result).to eq(
        text: <<~HTML,
          <b>#{origin.decorate.title}</b>

          #{origin.decorate.description_for_telegram}
        HTML
        reply_markup: {inline_keyboard: [[{text: "Назад", callback_data: "go_back:go_back"}]]},
        parse_mode: "HTML"
      )
    end
  end

  context "when the section-info bot command is selected" do
    let(:input_value) { BotCommand.origin.decorate.to_global_id.to_s }

    it "renders the general info of the section" do
      expect(result).to eq(
        text: BotCommand.origin.decorate.description_for_telegram,
        reply_markup: {inline_keyboard: [[{text: "Назад", callback_data: "go_back:go_back"}]]},
        parse_mode: "HTML"
      )
    end
  end

  context "when the characteristic-search subcommand is selected" do
    let(:input_value) { "search_by_characteristic" }

    it "lists the characteristics to improve" do
      options = Characteristic.ordered.map do |item|
        {text: item.title, callback_data: "origin:#{item.to_global_id}"}
      end

      expect(result).to eq(
        text: "Выбере характеристиру, которую хотите улучшить",
        reply_markup: {
          inline_keyboard: options.in_groups_of(2, false) + [[{text: "Назад", callback_data: "go_back:go_back"}]]
        },
        parse_mode: "HTML"
      )
    end
  end

  context "when a characteristic is selected by global id" do
    let(:characteristic) { Characteristic.ordered.first }
    let(:input_value) { characteristic.to_global_id.to_s }

    it "lists the origins tied to that characteristic, prefixed with the section info" do
      section_info = {
        text: BotCommand.origin.decorate.title,
        callback_data: "origin:#{BotCommand.origin.decorate.to_global_id}"
      }

      expect(result).to eq(
        text: "Выбери происхождение",
        reply_markup: {
          inline_keyboard: [[section_info], [{text: "Назад", callback_data: "go_back:go_back"}]]
        },
        parse_mode: "HTML"
      )
    end
  end

  context "when the input does not resolve to anything" do
    let(:input_value) { "not-a-gid" }

    it { is_expected.to eq(text: "Невалидный ввод", reply_markup: {}, parse_mode: "HTML") }
  end
end
