require "rails_helper"

RSpec.describe Invocation do
  it_behaves_like "publishable", :invocation
  it_behaves_like "multisearchable", :invocation
  it_behaves_like "mentionable", :invocation
  it_behaves_like "who_did_itable", :invocation

  describe "validations" do
    subject(:record) { build(:invocation, title: title, description: description) }

    let(:title) { "Agonizing Blast" }
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

    let!(:second) { create(:invocation, level: 2, title: "B title") }
    let!(:first) { create(:invocation, level: 1, title: "A title") }

    it { is_expected.to eq([first, second]) }
  end
end
