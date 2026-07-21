# Shared example for the EditionSourceable concern (app/models/concerns/edition_sourceable.rb).
#
# Usage — inside a model spec whose model includes EditionSourceable:
#   it_behaves_like "edition_sourceable", :origin
#
# The factory must build a valid record; edition_source falls back to the DB default.
RSpec.shared_examples "edition_sourceable" do |factory_name|
  describe "EditionSourceable" do
    it "exposes the shared edition_source enum mapping" do
      expect(described_class.edition_sources).to eq(EditionSourceable::EDITION_SOURCES.stringify_keys)
    end

    it "defaults edition_source to mm25" do
      expect(create(factory_name).edition_source).to eq("mm25")
    end
  end
end
