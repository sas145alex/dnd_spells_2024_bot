RSpec.describe "GET /admin/glossary_items" do
  subject { get admin_glossary_items_path }

  let(:admin) { create(:admin_user) }

  before do
    create(:glossary_item)
    sign_in(admin)
  end

  it { is_expected.to eq(200) }
end
