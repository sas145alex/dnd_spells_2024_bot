require "rails_helper"

RSpec.describe BotCommands::CharacterKlassSearch do
  subject(:result) { described_class.call(input_value: input_value, subklass_gid: subklass_gid) }

  let(:input_value) { nil }
  let(:subklass_gid) { nil }

  context "when nothing is selected" do
    let(:input_value) { nil }
    let(:subklass_gid) { nil }
    let!(:base_klass) do
      create(:character_klass, title: "Зуборез", original_title: "Toothcutter", published_at: Time.current)
    end

    it "renders the published top-level classes" do
      expect(result).to eq(
        text: "Выбери класс",
        reply_markup: {
          inline_keyboard: [
            [{text: base_klass.decorate.title, callback_data: "class:#{base_klass.to_global_id}"}],
            [{text: "Назад", callback_data: "go_back:go_back"}]
          ]
        },
        parse_mode: "HTML"
      )
    end
  end

  context "when a base class is selected" do
    let(:base_klass) do
      create(:character_klass, title: "Зуборез", original_title: "Toothcutter", published_at: Time.current)
    end
    let!(:subklass) do
      create(
        :character_klass,
        title: "Подзуборез",
        original_title: "Subtoothcutter",
        description: "sub desc",
        parent_klass: base_klass,
        published_at: Time.current
      )
    end
    let(:input_value) { base_klass.to_global_id.to_s }

    it "renders the subclasses with the base-class option" do
      expect(result).to eq(
        text: "Выбери подкласс",
        reply_markup: {
          inline_keyboard: [
            [{text: "Базовый класс", callback_data: "subclass:#{base_klass.decorate.to_global_id}"}],
            [{text: subklass.title, callback_data: "subclass:#{subklass.to_global_id}"}],
            [{text: "Назад", callback_data: "go_back:go_back"}]
          ]
        },
        parse_mode: "HTML"
      )
    end
  end

  context "when a subclass is selected" do
    let(:base_klass) do
      create(:character_klass, title: "Зуборез", original_title: "Toothcutter", published_at: Time.current)
    end
    let(:subklass) do
      create(
        :character_klass,
        title: "Подзуборез",
        original_title: "Subtoothcutter",
        description: "sub desc",
        parent_klass: base_klass,
        published_at: Time.current
      )
    end
    let(:subklass_gid) { subklass.to_global_id.to_s }

    it "renders the subclass description with abilities button" do
      expect(result).to eq(
        text: <<~HTML,
          <b>Выбрано:</b> #{subklass.decorate.title}

          #{subklass.decorate.description_for_telegram}
        HTML
        reply_markup: {
          inline_keyboard: [
            [{text: "Умения", callback_data: "abilities:#{subklass.decorate.to_global_id}"}],
            [{text: "Назад", callback_data: "go_back:go_back"}]
          ]
        },
        parse_mode: "HTML"
      )
    end
  end

  context "when the input does not resolve to a class" do
    let(:input_value) { "not-a-gid" }

    it { is_expected.to eq(text: "Невалидный ввод", reply_markup: {}, parse_mode: "HTML") }
  end
end
