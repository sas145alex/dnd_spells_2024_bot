require "rails_helper"

RSpec.describe Plan do
  it_behaves_like "publishable", :plan
  it_behaves_like "multisearchable", :plan
  it_behaves_like "mentionable", :plan
  it_behaves_like "who_did_itable", :plan

  describe "validations" do
    subject(:record) { build(:plan, title: title, description: description) }

    let(:title) { "Lightning Launcher" }
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

    let!(:second) { create(:plan, level: 2, title: "B title") }
    let!(:first) { create(:plan, level: 1, title: "A title") }

    it { is_expected.to eq([first, second]) }
  end
end
