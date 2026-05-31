require "rails_helper"

RSpec.describe BotCommands::CharacterKlassAbilitiesSearch do
  subject(:result) { described_class.call(input_value: input_value) }

  let(:input_value) { nil }
  let(:character_klass) do
    create(:character_klass, title: "Зуборез", original_title: "Toothcutter", published_at: Time.current)
  end

  context "when a character class is selected" do
    let!(:ability) do
      create(
        :character_klass_ability,
        title: "Ярость зубов",
        description: "rage",
        levels: [3],
        character_klass: character_klass,
        published_at: Time.current
      )
    end
    let(:input_value) { character_klass.to_global_id.to_s }

    it "lists the published abilities of the class" do
      expect(result).to eq(
        text: <<~HTML,
          Выбрано: <b>#{character_klass.decorate.title}</b>
          Выбери умение:
        HTML
        reply_markup: {
          inline_keyboard: [
            [{text: "[3] #{ability.decorate.title}", callback_data: "abilities:#{ability.decorate.to_global_id}"}],
            [{text: "Назад", callback_data: "go_back:go_back"}]
          ]
        },
        parse_mode: "HTML"
      )
    end
  end

  context "when an ability is selected" do
    let(:ability) do
      create(
        :character_klass_ability,
        title: "Ярость зубов",
        description: "rage details",
        levels: [3],
        character_klass: character_klass,
        published_at: Time.current
      )
    end
    let(:input_value) { ability.decorate.to_global_id.to_s }

    it "renders the ability description" do
      expect(result).to eq(
        text: ability.decorate.description_for_telegram,
        reply_markup: {inline_keyboard: [[{text: "Назад", callback_data: "go_back:go_back"}]]},
        parse_mode: "HTML"
      )
    end
  end

  context "when the input does not resolve to a class or ability" do
    let(:input_value) { "not-a-gid" }

    it { is_expected.to eq(text: "Невалидный ввод", reply_markup: {}, parse_mode: "HTML") }
  end
end
