require "rails_helper"

RSpec.describe BotCommands::SpellSearch do
  describe "#call" do
    subject(:result) do
      described_class.call(
        payload: payload,
        spell_gid: spell_gid,
        search_mode_activated: search_mode_activated
      )
    end

    let(:payload) { {} }
    let(:spell_gid) { nil }
    let(:search_mode_activated) { true }

    context "when a spell is selected by global id" do
      let(:spell) { create(:spell, level: 3, title: "Огненный шар", original_title: "Fireball") }
      let(:spell_gid) { spell.to_global_id }

      it "renders the spell description" do
        expect(result).to eq(
          text: spell.decorate.description_for_telegram,
          reply_markup: {inline_keyboard: []},
          parse_mode: "HTML"
        )
      end
    end

    context "when the selected global id is not a spell" do
      # `only: ::Spell` filters out non-Spell records, so locate returns nil without raising.
      let(:spell_gid) { create(:telegram_user).to_global_id }

      it "reports the spell was not found" do
        expect(result).to eq(
          text: "Указанное заклиннание не найдено",
          parse_mode: "HTML"
        )
      end
    end

    context "when the selected global id points at a deleted spell" do
      # A valid Spell GID for a deleted record makes locate raise RecordNotFound; selected_spell
      # rescues it to nil so the not-found branch handles deleted spells too.
      let(:spell_gid) { create(:spell).tap(&:destroy).to_global_id }

      it "reports the spell was not found" do
        expect(result).to eq(
          text: "Указанное заклиннание не найдено",
          parse_mode: "HTML"
        )
      end
    end

    context "when matching spells are found" do
      let!(:spell) do
        create(:spell, :published, level: 3, title: "Огненный шар", original_title: "Fireball")
      end
      let(:payload) { {"text" => "/spell огне"} }

      # The command maps results to *decorated* spells; the decorator yields the underlying
      # Spell GID so callback_data is `gid://app/Spell/…` and round-trips through selection.
      it "renders the search results keyboard with the model GID" do
        expect(result).to eq(
          text: "Найдено несколько вариантов. Выбери:\n\n",
          reply_markup: {
            inline_keyboard: [
              [{text: spell.decorate.title, callback_data: "spell:#{spell.to_global_id}"}]
            ]
          },
          parse_mode: "HTML"
        )
      end

      it "renders the spell when its keyboard callback_data is selected back" do
        keyboard = result[:reply_markup][:inline_keyboard]
        selected_gid = keyboard.first.first[:callback_data].sub("spell:", "")

        selection = described_class.call(payload: {}, spell_gid: selected_gid)

        expect(selection[:text]).to eq(spell.decorate.description_for_telegram)
      end
    end

    context "when no spells match the query" do
      let(:payload) { {"text" => "/spell zzzzzz"} }

      it "reports that nothing was found" do
        expect(result).to eq(
          text: "Вариантов не найдено",
          reply_markup: {},
          parse_mode: "HTML"
        )
      end
    end

    context "when the query is too short and search mode is active" do
      let(:payload) { {"text" => "/spell aa"} }

      it { expect(result[:text]).to include("режим поиска заклинаний") }
    end

    context "when the query is too short and search mode is inactive (chat)" do
      let(:payload) { {"text" => "/spell aa"} }
      let(:search_mode_activated) { false }

      it { expect(result[:text]).to include("/spell огненный") }
    end
  end
end
