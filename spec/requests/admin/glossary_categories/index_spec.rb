RSpec.describe "GET /admin/glossary_categories" do
  subject { get admin_glossary_categories_path }

  let(:admin) { create(:admin_user) }

  before do
    create(:glossary_category)
    sign_in(admin)
  end

  it { is_expected.to eq(200) }
end
