require "rails_helper"

RSpec.describe Segment do
  describe "associations" do
    it "belongs to a polymorphic resource" do
      reflection = described_class.reflect_on_association(:resource)

      expect(reflection.macro).to eq(:belongs_to)
      expect(reflection.options[:polymorphic]).to be(true)
    end

    it "belongs to a polymorphic attribute_resource" do
      reflection = described_class.reflect_on_association(:attribute_resource)

      expect(reflection.macro).to eq(:belongs_to)
      expect(reflection.options[:polymorphic]).to be(true)
    end
  end

  describe "persistence" do
    subject(:segment) { build(:segment) }

    it { is_expected.to be_valid }

    it "links a resource to an attribute_resource" do
      segment.save!

      expect(segment.resource).to be_present
      expect(segment.attribute_resource).to be_present
    end
  end
end
