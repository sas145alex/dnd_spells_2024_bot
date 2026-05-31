require "rails_helper"

RSpec.describe ArcaneShot do
  it_behaves_like "publishable", :arcane_shot
  it_behaves_like "multisearchable", :arcane_shot
  it_behaves_like "mentionable", :arcane_shot
  it_behaves_like "who_did_itable", :arcane_shot

  describe "validations" do
    subject(:record) { build(:arcane_shot, title: title, description: description) }

    let(:title) { "Arcane Shot" }
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

    let!(:second) { create(:arcane_shot, level: 2, title: "B title") }
    let!(:first) { create(:arcane_shot, level: 1, title: "A title") }

    it { is_expected.to eq([first, second]) }
  end
end
