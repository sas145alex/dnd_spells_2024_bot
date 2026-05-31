require "rails_helper"

RSpec.describe GlossaryCategory do
  describe "associations" do
    it "optionally belongs to a parent_category" do
      reflection = described_class.reflect_on_association(:parent_category)

      expect(reflection.macro).to eq(:belongs_to)
      expect(reflection.options[:class_name]).to eq("GlossaryCategory")
      expect(reflection.options[:optional]).to be(true)
    end

    it "has many subcategories" do
      reflection = described_class.reflect_on_association(:subcategories)

      expect(reflection.macro).to eq(:has_many)
      expect(reflection.options[:foreign_key]).to eq(:parent_category_id)
    end

    it "has many items" do
      reflection = described_class.reflect_on_association(:items)

      expect(reflection.macro).to eq(:has_many)
      expect(reflection.options[:class_name]).to eq("GlossaryItem")
    end
  end

  describe "validations" do
    subject(:record) { build(:glossary_category, title: title) }

    let(:title) { "Combat" }

    it { is_expected.to be_valid }

    context "without a title" do
      let(:title) { nil }

      it { is_expected.not_to be_valid }
    end
  end

  describe "scopes" do
    let!(:top) { create(:glossary_category, title: "Top") }
    let!(:child) { create(:glossary_category, title: "Child", parent_category: top) }

    describe ".top_level" do
      subject { described_class.top_level }

      it { is_expected.to include(top) }
      it { is_expected.not_to include(child) }
    end

    describe ".ordered" do
      subject { described_class.ordered.where(id: [top.id, child.id]) }

      it { is_expected.to eq([child, top]) }
    end
  end

  describe "#top_level?" do
    subject { record.top_level? }

    context "without a parent" do
      let(:record) { build(:glossary_category) }

      it { is_expected.to be(true) }
    end

    context "with a parent" do
      let(:record) { build(:glossary_category, parent_category: create(:glossary_category)) }

      it { is_expected.to be(false) }
    end
  end

  describe "#with_items?" do
    subject { category.with_items? }

    let(:category) { create(:glossary_category) }

    context "without items" do
      it { is_expected.to be(false) }
    end

    context "with an item" do
      before { create(:glossary_item, category: category) }

      it { is_expected.to be(true) }
    end
  end
end
