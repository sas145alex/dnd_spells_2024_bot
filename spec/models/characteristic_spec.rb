require "rails_helper"

RSpec.describe Characteristic do
  it_behaves_like "publishable", :characteristic
  it_behaves_like "mentionable", :characteristic
  it_behaves_like "segmentable", :characteristic
  it_behaves_like "who_did_itable", :characteristic

  describe "validations" do
    subject(:record) do
      build(:characteristic, title: title, description: description, published_at: published_at)
    end

    let(:title) { "Strength" }
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
    subject { described_class.ordered.where(id: [first.id, second.id]) }

    let!(:second) { create(:characteristic, title: "B title") }
    let!(:first) { create(:characteristic, title: "A title") }

    it { is_expected.to eq([first, second]) }
  end
end
