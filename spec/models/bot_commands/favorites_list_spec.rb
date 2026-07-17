require "rails_helper"

RSpec.describe BotCommands::FavoritesList do
  subject(:result) do
    described_class.call(user: user, input_value: input_value, page: page, response_type: response_type)
  end

  let(:user) { create(:telegram_user, :admin) }
  let(:input_value) { nil }
  let(:page) { nil }
  let(:response_type) { :edit }

  let(:answer) { result.first[:answer] }
  let(:keyboard) { answer[:reply_markup][:inline_keyboard] }
  let(:back_row) { [{text: "Назад", callback_data: "go_back:go_back"}] }

  context "when the user may not use favorites" do
    let(:user) { create(:telegram_user) }

    it { expect(answer[:text]).to include("недоступно") }
  end

  context "when the user has no favorites" do
    it "renders the empty-list notice with only a back button" do
      expect(answer[:text]).to include("нет избранного")
      expect(keyboard).to eq([back_row])
    end
  end

  context "when the user has favorites of different types" do
    let(:spell) { create(:spell) }
    let(:feat) { create(:feat) }

    before do
      create(:favorite, telegram_user: user, favoritable: spell)
      create(:favorite, telegram_user: user, favoritable: feat)
    end

    it "lists one button per favorite, labelled by global_search_title" do
      labels = keyboard.flatten.map { |button| button[:text] }
      expect(labels).to include(spell.decorate.global_search_title, feat.decorate.global_search_title)
    end

    it "keys each button by the record's global id under the favorites prefix" do
      spell_button = keyboard.flatten.find { |button| button[:text] == spell.decorate.global_search_title }
      expect(spell_button[:callback_data]).to eq("favorites:#{spell.to_global_id}")
    end

    it "leaves the rows unstarred — every card in this list is already a favorite" do
      labels = keyboard.flatten.map { |button| button[:text] }

      expect(labels).not_to include(a_string_including(Favorites::Marks::SYMBOL))
    end

    it { expect(keyboard.last).to eq(back_row) }
  end

  context "when a favorited record is selected by global id" do
    let(:spell) { create(:spell) }
    let(:input_value) { spell.to_global_id.to_s }

    before { create(:favorite, telegram_user: user, favoritable: spell) }

    it "renders the record's card with a back button" do
      expect(answer[:text]).to eq(spell.decorate.description_for_telegram)
      expect(keyboard.last).to eq(back_row)
    end

    it { expect(result.first[:type]).to eq(:edit) }
  end

  context "when the selected global id cannot be located" do
    let(:spell) { create(:spell) }
    let(:input_value) { spell.to_global_id.to_s }

    before { spell.destroy! }

    it { expect(answer[:text]).to include("не найдена") }
  end

  context "with more favorites than fit on a page" do
    before do
      create_list(:spell, described_class::FAVORITES_PER_PAGE + 1).each do |spell|
        create(:favorite, telegram_user: user, favoritable: spell)
      end
    end

    it "offers a next-page link on the first page" do
      links = keyboard.flatten.map { |button| button[:callback_data] }
      expect(links).to include("favorites_page:2")
    end

    context "on the second page" do
      let(:page) { 2 }

      it "offers a previous-page link" do
        links = keyboard.flatten.map { |button| button[:callback_data] }
        expect(links).to include("favorites_page:1")
      end
    end
  end
end
