require "rails_helper"

RSpec.describe Favorite do
  describe "associations" do
    it "belongs to a telegram_user" do
      reflection = described_class.reflect_on_association(:telegram_user)

      expect(reflection.macro).to eq(:belongs_to)
    end

    it "belongs to a polymorphic favoritable" do
      reflection = described_class.reflect_on_association(:favoritable)

      expect(reflection.macro).to eq(:belongs_to)
      expect(reflection.options[:polymorphic]).to be(true)
    end
  end

  describe "uniqueness" do
    subject(:duplicate) { build(:favorite, telegram_user: user, favoritable: spell) }

    let(:user) { create(:telegram_user) }
    let(:spell) { create(:spell) }

    before { create(:favorite, telegram_user: user, favoritable: spell) }

    it { is_expected.to be_invalid }

    context "when the same record is favorited by a different user" do
      subject(:other_user_favorite) { build(:favorite, telegram_user: create(:telegram_user), favoritable: spell) }

      it { is_expected.to be_valid }
    end

    context "when the same user favorites a different record" do
      subject(:other_record_favorite) { build(:favorite, telegram_user: user, favoritable: create(:spell)) }

      it { is_expected.to be_valid }
    end
  end
end
