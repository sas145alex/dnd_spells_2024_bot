require "rails_helper"

RSpec.describe Presenters::LeafCard do
  subject(:answer) { described_class.call(object: record, user: user, **options) }

  let(:record) { create(:spell) }
  let(:user) { create(:telegram_user, :admin) }
  let(:options) { {} }

  let(:keyboard) { answer[:reply_markup][:inline_keyboard] }
  let(:fav_button) { keyboard.flatten.find { |b| b[:callback_data].to_s.start_with?("fav:") } }

  it "returns the standard answer hash" do
    expect(answer).to include(text: be_present, parse_mode: "HTML")
    expect(answer[:reply_markup]).to have_key(:inline_keyboard)
  end

  it "defaults the text to the decorated description" do
    expect(answer[:text]).to eq(record.decorate.description_for_telegram)
  end

  context "when text is supplied" do
    let(:options) { {text: "<b>custom</b>"} }

    it { expect(answer[:text]).to eq("<b>custom</b>") }
  end

  describe "the favorite button" do
    context "when the user may use favorites and has not favorited the record" do
      it "offers to add to favorites, keyed by the record's global id" do
        expect(fav_button).to eq(text: "⭐ В избранное", callback_data: "fav:#{record.to_global_id}")
      end
    end

    context "when the record is already favorited" do
      before { create(:favorite, telegram_user: user, favoritable: record) }

      it { expect(fav_button[:text]).to eq("❌ Убрать из избранного") }
    end

    context "when the user is not an admin" do
      let(:user) { create(:telegram_user) }

      it { expect(fav_button).to eq(text: "⭐ В избранное", callback_data: "fav:#{record.to_global_id}") }
    end

    # The cap is enforced on the tap, not on the render — the card still offers the button.
    context "when the user is at the free limit" do
      let(:user) { create(:telegram_user) }

      before { create_list(:favorite, Favorites::Policy::FREE_LIMIT, telegram_user: user) }

      it { expect(fav_button[:text]).to eq("⭐ В избранное") }
    end

    context "when there is no user" do
      let(:user) { nil }

      it { expect(fav_button).to be_nil }
    end
  end

  describe "the back button" do
    context "when back_button is true (default)" do
      it { expect(keyboard.last).to eq([{text: "Назад", callback_data: "go_back:go_back"}]) }
    end

    context "when back_button is false" do
      let(:options) { {back_button: false} }

      it { expect(keyboard.flatten).not_to include(hash_including(callback_data: "go_back:go_back")) }
    end
  end

  describe "the locale toggle" do
    let(:record) { create(:bastion) }
    let(:locale_button) { keyboard.flatten.find { |b| b[:callback_data].to_s.start_with?("search_en:", "search:") } }

    context "when locale_toggle is false (default)" do
      it { expect(locale_button).to be_nil }
    end

    context "when locale_toggle is true and the record is bilingual" do
      let(:options) { {locale_toggle: true} }

      it "offers an EN toggle" do
        expect(locale_button).to eq(text: "EN 🇺🇸", callback_data: "search_en:#{record.to_global_id}")
      end
    end

    context "when rendering in EN with the toggle on" do
      let(:options) { {locale_toggle: true, locale: :en} }

      it "offers a RU toggle" do
        expect(locale_button).to eq(text: "RU 🇷🇺", callback_data: "search:#{record.to_global_id}")
      end
    end
  end

  describe "extra rows" do
    let(:options) { {extra_rows: [[{text: "Умения", callback_data: "abilities:1"}]]} }

    it "inserts the extra rows between the mentions and the back button" do
      expect(keyboard[-2]).to eq([{text: "Умения", callback_data: "abilities:1"}])
      expect(keyboard.last).to eq([{text: "Назад", callback_data: "go_back:go_back"}])
    end
  end

  describe "mention buttons" do
    let(:other) { create(:feat) }
    let!(:mention) { Mention.create!(mentionable: record, another_mentionable: other) }

    it "renders a button per mention" do
      expect(keyboard.flatten).to include(
        hash_including(callback_data: "pick_mention:#{mention.id}")
      )
    end
  end
end
