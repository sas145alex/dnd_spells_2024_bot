require "rails_helper"

RSpec.describe Maneuver do
  it_behaves_like "publishable", :maneuver
  it_behaves_like "multisearchable", :maneuver
  it_behaves_like "mentionable", :maneuver
  it_behaves_like "who_did_itable", :maneuver

  describe "validations" do
    subject(:record) { build(:maneuver, title: title, description: description) }

    let(:title) { "Disarming Attack" }
    let(:description) { "A valid description." }

    it { is_expected.to be_valid }

    context "without a title" do
      let(:title) { nil }

      it { is_expected.not_to be_valid }
    end

    context "with a too-short title" do
      let(:title) { "ab" }

      it { is_expected.not_to be_valid }
    end

    context "without a description" do
      let(:description) { nil }

      it { is_expected.not_to be_valid }
    end
  end

  describe ".ordered" do
    subject { described_class.ordered }

    let!(:second) { create(:maneuver, title: "B title") }
    let!(:first) { create(:maneuver, title: "A title") }

    it { is_expected.to eq([first, second]) }
  end
end
