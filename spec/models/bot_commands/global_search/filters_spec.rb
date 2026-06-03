require "rails_helper"

RSpec.describe BotCommands::GlobalSearch::Filters do
  subject(:result) { described_class.call(user: user, selected_klass: selected_klass) }

  let(:initial_unselected) { [] }
  let(:user) { create(:telegram_user, unselected_search_categories: initial_unselected) }
  let(:selected_klass) { nil }

  # used_klasses is class-derived and memoized at the class level — reset so the memo
  # is rebuilt against whatever content classes are loaded for this run.
  before { described_class._reset_memoized_commands }
  after { described_class._reset_memoized_commands }

  def expected_inline_keyboard(unselected)
    options = described_class.all_klasses.map do |klass|
      symbol = unselected.include?(klass.to_s) ? "🚫" : "✅"
      {text: "#{symbol} #{klass.model_name.human}", callback_data: "search_filters:#{klass}"}
    end
    options.in_groups_of(2, false)
  end

  context "when no klass is selected" do
    let(:selected_klass) { nil }

    it "edits the message with every category marked selected" do
      is_expected.to eq([
        {
          type: :edit,
          answer: {
            text: "Разделы справочника по которым проводится поиск",
            reply_markup: {inline_keyboard: expected_inline_keyboard([])},
            parse_mode: "HTML"
          }
        }
      ])
    end
  end

  context "when a not-yet-excluded klass is selected" do
    let(:selected_klass) { "Spell" }

    it "adds the klass to the user's unselected categories" do
      expect { result }.to change { user.reload.unselected_search_categories }.from([]).to(["Spell"])
    end

    it "renders that category as unselected" do
      expect(result.first.dig(:answer, :reply_markup, :inline_keyboard))
        .to eq(expected_inline_keyboard(["Spell"]))
    end
  end

  context "when an already-excluded klass is selected" do
    let(:initial_unselected) { ["Spell"] }
    let(:selected_klass) { "Spell" }

    it "removes the klass from the user's unselected categories" do
      expect { result }.to change { user.reload.unselected_search_categories }.from(["Spell"]).to([])
    end
  end
end
