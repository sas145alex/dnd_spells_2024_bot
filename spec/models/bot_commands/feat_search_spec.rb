require "rails_helper"

RSpec.describe BotCommands::FeatSearch do
  subject(:result) { described_class.call(input_value: input_value) }

  let(:input_value) { nil }

  context "when the input is blank" do
    let(:input_value) { nil }

    it "renders the category enum options" do
      enum_options = Feat.human_enum_names(:category, locale: "ru").map do |translation, raw|
        {text: translation, callback_data: "feat:#{raw}"}
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

  context "when a non-general category is selected" do
    let(:input_value) { "origin" }
    let!(:feat) { create(:feat, title: "Одаренный", category: "origin", published_at: Time.current) }

    it "lists the feats of the category" do
      expect(result).to eq(
        text: "Выбери черту",
        reply_markup: {
          inline_keyboard: [
            [{text: feat.title, callback_data: "feat:#{feat.to_global_id}"}],
            [{text: "Назад", callback_data: "go_back:go_back"}]
          ]
        },
        parse_mode: "HTML"
      )
    end
  end

  context "when the general category is selected" do
    let(:input_value) { "general" }
    let!(:feat) { create(:feat, title: "Меткий стрелок", category: "general", published_at: Time.current) }

    it "prepends the characteristic-search subcommand" do
      expect(result).to eq(
        text: "Выбери черту",
        reply_markup: {
          inline_keyboard: [
            [{text: "Поиск по хар-ке", callback_data: "feat:search_by_characteristic"}],
            [{text: feat.title, callback_data: "feat:#{feat.to_global_id}"}],
            [{text: "Назад", callback_data: "go_back:go_back"}]
          ]
        },
        parse_mode: "HTML"
      )
    end
  end

  context "when a feat is selected by global id" do
    let(:feat) { create(:feat, title: "Одаренный", category: "origin", description: "gifted", published_at: Time.current) }
    let(:input_value) { feat.to_global_id.to_s }

    it "renders the feat details" do
      expect(result).to eq(
        text: <<~HTML,
          <b>#{feat.decorate.title}</b>
          <i>#{feat.decorate.human_enum_name(:category, locale: "ru")}</i>

          #{feat.decorate.description_for_telegram}
        HTML
        reply_markup: {inline_keyboard: [[{text: "Назад", callback_data: "go_back:go_back"}]]},
        parse_mode: "HTML"
      )
    end
  end

  context "when the input does not resolve to a feat" do
    let(:input_value) { "not-a-gid" }

    it { is_expected.to eq(text: "Невалидный ввод", reply_markup: {}, parse_mode: "HTML") }
  end
end
