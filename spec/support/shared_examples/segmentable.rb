# Shared example for the Segmentable concern (app/models/concerns/segmentable.rb).
#
# Usage — inside a model spec whose model includes Segmentable:
#   it_behaves_like "segmentable", :characteristic
#
# Verifies the two polymorphic Segment associations the concern declares
# (`segment_items` as :resource and `segment_categories` as :attribute_resource)
# and that nested attributes for segment_items are accepted.
RSpec.shared_examples "segmentable" do |factory_name|
  describe "Segmentable" do
    subject(:record) { create(factory_name) }

    describe "associations" do
      it "has a polymorphic :segment_items association" do
        reflection = described_class.reflect_on_association(:segment_items)

        expect(reflection.macro).to eq(:has_many)
        expect(reflection.options[:as]).to eq(:resource)
        expect(reflection.options[:class_name]).to eq("Segment")
      end

      it "has a polymorphic :segment_categories association" do
        reflection = described_class.reflect_on_association(:segment_categories)

        expect(reflection.macro).to eq(:has_many)
        expect(reflection.options[:as]).to eq(:attribute_resource)
        expect(reflection.options[:class_name]).to eq("Segment")
      end
    end

    it "accepts nested attributes for segment_items" do
      expect(record).to respond_to(:segment_items_attributes=)
    end

    describe "#segment_items" do
      it "returns segments where the record is the resource" do
        category = create(factory_name)
        segment = Segment.create!(resource: record, attribute_resource: category)

        expect(record.segment_items).to include(segment)
      end
    end
  end
end
