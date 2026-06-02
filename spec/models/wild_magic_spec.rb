require "rails_helper"

RSpec.describe WildMagic do
  it_behaves_like "who_did_itable", :wild_magic

  # The shared "mentionable" example creates two records via the factory, which
  # collides with the unique `roll` constraint; assert the concern inline instead.
  describe "Mentionable" do
    it "has a polymorphic :mentions association" do
      reflection = described_class.reflect_on_association(:mentions)

      expect(reflection.macro).to eq(:has_many)
      expect(reflection.options[:as]).to eq(:mentionable)
      expect(reflection.options[:class_name]).to eq("Mention")
    end

    it "records mentions where it is the mentionable" do
      record = create(:wild_magic, roll: 1..10)
      other = create(:wild_magic, roll: 11..20)
      mention = Mention.create!(mentionable: record, another_mentionable: other)

      expect(record.mentions).to include(mention)
    end
  end

  describe "validations" do
    subject(:record) { build(:wild_magic, description: description) }

    let(:description) { "A valid description." }

    it { is_expected.to be_valid }

    context "with a too-short description" do
      let(:description) { "abc" }

      it { is_expected.not_to be_valid }
    end

    context "with a blank description" do
      let(:description) { "" }

      it { is_expected.not_to be_valid }
    end
  end

  describe ".ordered" do
    subject { described_class.ordered }

    let!(:second) { create(:wild_magic, roll: 50..60) }
    let!(:first) { create(:wild_magic, roll: 1..10) }

    it { is_expected.to eq([first, second]) }
  end

  describe ".find_by_roll" do
    subject { described_class.find_by_roll(roll_value) }

    let!(:low_band) { create(:wild_magic, roll: 1..10) }
    let!(:high_band) { create(:wild_magic, roll: 90..100) }

    context "when the value is inside the low band" do
      let(:roll_value) { 5 }

      it { is_expected.to eq(low_band) }
    end

    context "when the value is inside the high band" do
      let(:roll_value) { 95 }

      it { is_expected.to eq(high_band) }
    end
  end
end
