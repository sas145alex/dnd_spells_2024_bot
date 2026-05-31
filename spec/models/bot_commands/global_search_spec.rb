require "rails_helper"

RSpec.describe BotCommands::GlobalSearch do
  describe ".normalize_input" do
    subject(:normalized) { described_class.normalize_input(raw_input) }

    context "when the input carries a command prefix and extra whitespace" do
      let(:raw_input) { "/search@sneaky_library_bot   огненный   шар " }

      it { is_expected.to eq("огненный шар") }
    end
  end

  describe ".fetch_page_from" do
    subject(:page) { described_class.fetch_page_from(raw_input) }

    context "when no page delimiter is present" do
      let(:raw_input) { "огненный шар" }

      it { is_expected.to eq(1) }
    end

    context "when a page is appended" do
      let(:raw_input) { "огненный шар||3" }

      it { is_expected.to eq(3) }
    end
  end

  describe "#call" do
    subject(:result) do
      described_class.call(user: user, payload: payload, locale: locale, record_gid: record_gid, page: page)
    end

    let(:user) { create(:telegram_user) }
    let(:payload) { {} }
    let(:locale) { :ru }
    let(:record_gid) { nil }
    let(:page) { nil }

    context "when a record is selected by global id" do
      let(:spell) { create(:spell, :published, level: 3, title: "Огненный шар", original_title: "Fireball") }
      let(:record_gid) { spell.to_global_id.to_s }

      before { allow(Telegram::SpellMetricsJob).to receive(:perform_later) }

      it "renders the record description as a single message" do
        expect(result).to eq(
          [
            {
              type: :message,
              answer: {
                text: spell.decorate.description_for_telegram,
                reply_markup: {inline_keyboard: []},
                parse_mode: "HTML"
              }
            }
          ]
        )
      end

      it "schedules spell metrics for the selected spell" do
        result

        expect(Telegram::SpellMetricsJob).to have_received(:perform_later).with(spell_gid: spell.to_global_id.to_s)
      end
    end

    context "when the global id is present but unparseable" do
      # A real GID for a deleted record raises RecordNotFound (latent bug — see report);
      # the not-found branch is only reachable when locate returns nil, i.e. malformed data.
      let(:record_gid) { "not-a-valid-gid" }

      it "reports the object was not found" do
        expect(result).to eq(
          [
            {
              type: :message,
              answer: {
                text: "Указанный объект не найден",
                parse_mode: "HTML"
              }
            }
          ]
        )
      end
    end

    context "when the query is too short" do
      let(:payload) { {"text" => "/search aa"} }

      it "returns the invalid-input help message" do
        expect(result.size).to eq(1)
        expect(result.first[:type]).to eq(:message)
        expect(result.first[:answer][:text]).to include("Минимум - 3, максимум - 30")
      end
    end

    context "when nothing matches the query" do
      let(:payload) { {"text" => "/search zzzzzzqqqq"} }

      it "reports nothing was found with a filters button" do
        expect(result).to eq(
          [
            {
              type: :message,
              answer: {
                text: "Вариантов не найдено",
                reply_markup: {
                  inline_keyboard: [[{text: "Фильтры 📃", callback_data: "search_filters:"}]]
                },
                parse_mode: "HTML"
              }
            }
          ]
        )
      end
    end

    context "when matching records are found" do
      let!(:spell) do
        create(:spell, :published, level: 3, title: "Огненный шар", original_title: "Fireball")
      end
      let(:payload) { {"text" => "/search огненный шар"} }

      before do
        Multisearchable.regenerate_all_searchable_columns!
        Multisearchable.regenerate_all_multisearchables!
      end

      it "renders search results with a Spell button ordered first" do
        decorated = spell.decorate

        expect(result.size).to eq(1)
        expect(result.first[:type]).to eq(:message)

        answer = result.first[:answer]
        expect(answer[:parse_mode]).to eq("HTML")
        expect(answer[:text]).to include("<b>Поиск</b> - огненный шар")

        keyboard = answer[:reply_markup][:inline_keyboard]
        expect(keyboard.first).to eq([{text: "Фильтры 📃", callback_data: "search_filters:"}])
        expect(keyboard).to include(
          [{text: decorated.global_search_title, callback_data: "search:#{decorated.to_global_id}"}]
        )
      end
    end
  end
end
