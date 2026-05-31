# Shared example for the Mentionable concern (app/models/concerns/mentionable.rb).
#
# Usage — inside a model spec whose model includes Mentionable:
#   it_behaves_like "mentionable", :spell
#
# Verifies the two polymorphic Mention associations the concern declares
# (`mentions` as :mentionable and `mentioned_mentions` as :another_mentionable)
# and that nested attributes for mentions are accepted.
RSpec.shared_examples "mentionable" do |factory_name|
  describe "Mentionable" do
    subject(:record) { create(factory_name) }

    describe "associations" do
      it "has a polymorphic :mentions association" do
        reflection = described_class.reflect_on_association(:mentions)

        expect(reflection.macro).to eq(:has_many)
        expect(reflection.options[:as]).to eq(:mentionable)
        expect(reflection.options[:class_name]).to eq("Mention")
      end

      it "has a polymorphic :mentioned_mentions association" do
        reflection = described_class.reflect_on_association(:mentioned_mentions)

        expect(reflection.macro).to eq(:has_many)
        expect(reflection.options[:as]).to eq(:another_mentionable)
        expect(reflection.options[:class_name]).to eq("Mention")
      end
    end

    it "accepts nested attributes for mentions" do
      expect(described_class).to respond_to(:reflect_on_association)
      expect(record).to respond_to(:mentions_attributes=)
    end

    describe "#mentions" do
      it "returns mentions where the record is the mentionable" do
        other = create(factory_name)
        mention = Mention.create!(mentionable: record, another_mentionable: other)

        expect(record.mentions).to include(mention)
      end
    end
  end
end
