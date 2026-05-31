require "rails_helper"

RSpec.describe PsionicPower do
  it_behaves_like "publishable", :psionic_power
  it_behaves_like "multisearchable", :psionic_power
  it_behaves_like "mentionable", :psionic_power
  it_behaves_like "who_did_itable", :psionic_power

  describe "validations" do
    subject(:record) { build(:psionic_power, title: title, description: description) }

    let(:title) { "Mind Sliver" }
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

    let!(:second) { create(:psionic_power, level: 2, title: "B title") }
    let!(:first) { create(:psionic_power, level: 1, title: "A title") }

    it { is_expected.to eq([first, second]) }
  end
end
