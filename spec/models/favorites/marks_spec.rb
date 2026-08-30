require "rails_helper"

RSpec.describe Favorites::Marks do
  subject(:label) { described_class.for(records, user).label(record, title) }

  let(:user) { create(:telegram_user) }
  let(:spell) { create(:spell, title: "Огненный шар") }
  let(:records) { [spell] }
  let(:record) { spell }
  let(:title) { spell.title }
  let(:starred_title) { "#{described_class::SYMBOL} #{title}" }

  context "when the record is favorited by the user" do
    before { create(:favorite, telegram_user: user, favoritable: spell) }

    it { is_expected.to eq(starred_title) }

    context "when the records arrive decorated" do
      let(:records) { [spell.decorate] }
      let(:record) { spell.decorate }

      it { is_expected.to eq(starred_title) }
    end

    context "when the user is an admin" do
      let(:user) { create(:telegram_user, :admin) }

      it { is_expected.to eq(starred_title) }
    end
  end

  context "when there is no user" do
    let(:user) { nil }

    it { is_expected.to eq(title) }
  end

  context "when the record is not favorited" do
    it { is_expected.to eq(title) }
  end

  context "when only another user favorited the record" do
    before { create(:favorite, telegram_user: create(:telegram_user, :admin), favoritable: spell) }

    it { is_expected.to eq(title) }
  end

  context "when the row is a PORO standing in for the record" do
    let(:ability) { create(:character_klass_ability, title: "Ярость") }
    let(:variant) do
      Presenters::CharacterAbilitiesPresenter::Variant.new(
        id: ability.id,
        title: ability.title,
        level: 1,
        to_global_id: ability.to_global_id
      )
    end
    let(:records) { [variant] }
    let(:record) { variant }
    let(:title) { variant.title }

    before { create(:favorite, telegram_user: user, favoritable: ability) }

    it { is_expected.to eq(starred_title) }
  end

  context "when the screen mixes favoritable and plain records" do
    let(:characteristic) { create(:characteristic) }
    let(:records) { [spell, characteristic] }
    let(:record) { characteristic }
    let(:title) { characteristic.title }

    before { create(:favorite, telegram_user: user, favoritable: spell) }

    it { is_expected.to eq(title) }
  end

  describe "query count" do
    let(:spells) { create_list(:spell, 3) }

    before { spells.each { |spell| create(:favorite, telegram_user: user, favoritable: spell) } }

    it "resolves the whole screen with one query instead of one per row" do
      marks = described_class.for(spells, user)

      expect(count_queries { spells.each { |spell| marks.label(spell, spell.title) } }).to eq(1)
    end
  end

  def count_queries
    queries = 0
    subscriber = ActiveSupport::Notifications.subscribe("sql.active_record") do |_name, _start, _finish, _id, payload|
      queries += 1 unless payload[:name].in?(["SCHEMA", "TRANSACTION"])
    end
    yield
    queries
  ensure
    ActiveSupport::Notifications.unsubscribe(subscriber)
  end
end
