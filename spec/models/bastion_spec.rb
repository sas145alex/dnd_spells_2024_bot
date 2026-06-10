require "rails_helper"

RSpec.describe Bastion do
  it_behaves_like "publishable", :bastion
  it_behaves_like "multisearchable", :bastion
  it_behaves_like "mentionable", :bastion
  it_behaves_like "who_did_itable", :bastion

  describe "validations" do
    subject(:record) { build(:bastion, title: title, description: description, category: category, level: level) }

    let(:title) { "Спальня" }
    let(:description) { "A valid description." }
    let(:category) { :construction }
    let(:level) { 0 }

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

    context "without a category" do
      let(:category) { nil }

      it { is_expected.not_to be_valid }
    end

    context "when leveling with a zero level" do
      let(:category) { :leveling }
      let(:level) { 0 }

      it { is_expected.not_to be_valid }
    end

    context "when leveling with a positive level" do
      let(:category) { :leveling }
      let(:level) { 5 }

      it { is_expected.to be_valid }
    end

    context "when basic with a non-zero level" do
      let(:category) { :construction }
      let(:level) { 5 }

      it { is_expected.not_to be_valid }
    end
  end

  describe ".ordered" do
    subject { described_class.ordered }

    let!(:second) { create(:bastion, title: "B title") }
    let!(:first) { create(:bastion, title: "A title") }

    it { is_expected.to eq([first, second]) }
  end
end
