require "rails_helper"

RSpec.describe GlossaryItem do
  it_behaves_like "publishable", :glossary_item
  it_behaves_like "multisearchable", :glossary_item
  it_behaves_like "mentionable", :glossary_item
  it_behaves_like "who_did_itable", :glossary_item

  describe "associations" do
    it "belongs to a category" do
      reflection = described_class.reflect_on_association(:category)

      expect(reflection.macro).to eq(:belongs_to)
      expect(reflection.options[:class_name]).to eq("GlossaryCategory")
    end
  end

  describe "validations" do
    subject(:record) do
      build(:glossary_item, title: title, description: description, published_at: published_at)
    end

    let(:title) { "Advantage" }
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

    let!(:second) { create(:glossary_item, title: "B title") }
    let!(:first) { create(:glossary_item, title: "A title") }

    it { is_expected.to eq([first, second]) }
  end
end
