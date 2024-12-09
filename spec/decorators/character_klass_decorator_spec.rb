RSpec.describe CharacterKlassDecorator do
  describe ".links_store" do
    subject(:method) { described_class.links_store }

    it "returns an hash" do
      expect(method).to be_a(Hash)
      expect(method.keys.size).to be_positive
    end
  end

  describe ".build_link_to_ability_table" do
    subject(:method) { described_class.build_link_to_ability_table(klass_title) }

    let(:klass_title) { "" }

    it "returns nil" do
      expect(method).to be_nil
    end

    context "when specify klass title which must have file in public directory" do
      let(:klass_title) { "warlock" }

      it "does not return nil" do
        expect(method).not_to be_nil
      end
    end
  end
end
