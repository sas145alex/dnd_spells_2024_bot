# Shared example for the Publishable concern (app/models/concerns/publishable.rb).
#
# Usage — inside a model spec whose model includes Publishable:
#   it_behaves_like "publishable", :spell
#
# The factory must accept a `published_at:` attribute (every content model does).
RSpec.shared_examples "publishable" do |factory_name|
  describe "Publishable" do
    let!(:published) { create(factory_name, published_at: Time.current) }
    let!(:not_published) { create(factory_name, published_at: nil) }

    describe ".published" do
      it "returns only records with published_at set" do
        expect(described_class.published).to include(published)
        expect(described_class.published).not_to include(not_published)
      end
    end

    describe ".not_published" do
      it "returns only records without published_at" do
        expect(described_class.not_published).to include(not_published)
        expect(described_class.not_published).not_to include(published)
      end
    end

    describe "#published?" do
      it { expect(published).to be_published }
      it { expect(not_published).not_to be_published }
    end

    describe "#publish!" do
      it "sets published_at" do
        expect { not_published.publish! }
          .to change { not_published.reload.published_at }.from(nil)
      end
    end

    describe "#unpublish!" do
      it "clears published_at" do
        expect { published.unpublish! }
          .to change { published.reload.published_at }.to(nil)
      end
    end
  end
end
