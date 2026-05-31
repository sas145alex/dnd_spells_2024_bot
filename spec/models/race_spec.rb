require "rails_helper"

RSpec.describe Race do
  it_behaves_like "publishable", :race
  it_behaves_like "multisearchable", :race
  it_behaves_like "mentionable", :race
  it_behaves_like "who_did_itable", :race

  describe "validations" do
    subject(:record) do
      build(:race, title: title, description: description, published_at: published_at)
    end

    let(:title) { "Elf" }
    let(:description) { "A valid description." }
    let(:published_at) { nil }

    it { is_expected.to be_valid }

    context "without a title" do
      let(:title) { nil }

      it { is_expected.not_to be_valid }
    end

    context "with a too-short title" do
      let(:title) { "ab" }

      it { is_expected.not_to be_valid }
    end

    context "when published without a description" do
      let(:published_at) { Time.current }
      let(:description) { nil }

      it { is_expected.not_to be_valid }
    end

    context "when unpublished without a description" do
      let(:description) { nil }

      it { is_expected.to be_valid }
    end
  end

  describe ".ordered" do
    subject { described_class.ordered }

    let!(:second) { create(:race, title: "B title") }
    let!(:first) { create(:race, title: "A title") }

    it { is_expected.to eq([first, second]) }
  end
end
