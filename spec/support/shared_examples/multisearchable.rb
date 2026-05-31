# Shared example for the Multisearchable concern (app/models/concerns/multisearchable.rb).
#
# Usage — inside a model spec whose model includes Multisearchable:
#   it_behaves_like "multisearchable", :spell
#
# Verifies that the record's `searchable_title` is built from `Multisearchable.format`
# (downcased, ё→е, whitespace-collapsed) and that `regenerate_searchable_columns!`
# rebuilds it from the current title/original_title.
RSpec.shared_examples "multisearchable" do |factory_name|
  describe "Multisearchable" do
    subject(:record) { create(factory_name, title: title, original_title: original_title) }

    let(:title) { "Огнённый  Шар" }
    let(:original_title) { "Fireball" }

    describe "#searchable_title" do
      it "is populated via Multisearchable.format on create" do
        expect(record.searchable_title)
          .to eq(Multisearchable.format(title, original_title))
      end

      it "is downcased and normalizes ё to е" do
        expect(record.searchable_title).to eq("огненный шар fireball")
      end
    end

    describe "#regenerate_searchable_columns!" do
      let(:new_title) { "Лёд" }

      it "rebuilds searchable_title from the current title" do
        record.update_column(:title, new_title)

        expect { record.regenerate_searchable_columns! }
          .to change { record.reload.searchable_title }
          .to(Multisearchable.format(new_title, original_title))
      end
    end
  end
end
