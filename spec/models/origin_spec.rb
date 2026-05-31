require "rails_helper"

RSpec.describe Origin do
  it_behaves_like "publishable", :origin
  it_behaves_like "multisearchable", :origin
  it_behaves_like "mentionable", :origin
  it_behaves_like "segmentable", :origin
  it_behaves_like "who_did_itable", :origin

  describe "validations" do
    subject(:record) do
      build(:origin, title: title, description: description, published_at: published_at)
    end

    let(:title) { "Acolyte" }
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

    let!(:second) { create(:origin, title: "B title") }
    let!(:first) { create(:origin, title: "A title") }

    it { is_expected.to eq([first, second]) }
  end
end
