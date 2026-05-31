require "rails_helper"

RSpec.describe Feat do
  it_behaves_like "publishable", :feat
  it_behaves_like "multisearchable", :feat
  it_behaves_like "mentionable", :feat
  it_behaves_like "segmentable", :feat
  it_behaves_like "who_did_itable", :feat

  describe "validations" do
    subject(:record) do
      build(:feat, title: title, category: category)
    end

    let(:title) { "Alert" }
    let(:category) { :general }

    it { is_expected.to be_valid }

    context "without a title" do
      let(:title) { nil }

      it { is_expected.not_to be_valid }
    end

    context "with a too-short title" do
      let(:title) { "ab" }

      it { is_expected.not_to be_valid }
    end

    context "without a category" do
      let(:category) { nil }

      it { is_expected.not_to be_valid }
    end

    context "when published with a too-short description" do
      subject(:record) do
        build(:feat, title: title, category: category, description: "x", published_at: Time.current)
      end

      it { is_expected.not_to be_valid }
    end
  end

  describe "category enum" do
    it "maps values" do
      expect(described_class.categories).to eq(
        "general" => "general",
        "origin" => "origin",
        "fighting_style" => "fighting_style",
        "epic_boon" => "epic_boon"
      )
    end
  end

  describe ".ordered" do
    subject { described_class.ordered }

    let!(:second) { create(:feat, category: :origin, title: "A title") }
    let!(:first) { create(:feat, category: :general, title: "Z title") }

    it "orders by category then title" do
      is_expected.to eq([first, second])
    end
  end
end
