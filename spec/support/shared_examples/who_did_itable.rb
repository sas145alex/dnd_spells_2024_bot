# Shared example for the WhoDidItable concern (app/models/concerns/who_did_itable.rb).
#
# Usage — inside a model spec whose model includes WhoDidItable:
#   it_behaves_like "who_did_itable", :spell
#
# Verifies the optional `created_by` / `updated_by` belongs_to associations
# (both pointing at AdminUser) that the concern declares.
RSpec.shared_examples "who_did_itable" do |factory_name|
  describe "WhoDidItable" do
    subject(:record) { create(factory_name) }

    describe "associations" do
      it "belongs to an optional AdminUser as :created_by" do
        reflection = described_class.reflect_on_association(:created_by)

        expect(reflection.macro).to eq(:belongs_to)
        expect(reflection.options[:class_name]).to eq("AdminUser")
        expect(reflection.options[:optional]).to be(true)
      end

      it "belongs to an optional AdminUser as :updated_by" do
        reflection = described_class.reflect_on_association(:updated_by)

        expect(reflection.macro).to eq(:belongs_to)
        expect(reflection.options[:class_name]).to eq("AdminUser")
        expect(reflection.options[:optional]).to be(true)
      end
    end

    it "is valid without created_by/updated_by" do
      expect(record.created_by).to be_nil
      expect(record.updated_by).to be_nil
      expect(record).to be_valid
    end

    describe "assigning a creator" do
      let(:admin) { create(:admin_user) }

      it "persists created_by" do
        record.update!(created_by: admin)

        expect(record.reload.created_by).to eq(admin)
      end
    end
  end
end
