require "rails_helper"

RSpec.describe Metamagic do
  it_behaves_like "publishable", :metamagic
  it_behaves_like "multisearchable", :metamagic
  it_behaves_like "mentionable", :metamagic
  it_behaves_like "who_did_itable", :metamagic

  describe "validations" do
    subject(:record) { build(:metamagic, title: title, description: description) }

    let(:title) { "Quickened Spell" }
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

    let!(:second) { create(:metamagic, title: "B title", sorcery_points: 2) }
    let!(:first) { create(:metamagic, title: "A title", sorcery_points: 1) }

    it { is_expected.to eq([first, second]) }
  end
end
