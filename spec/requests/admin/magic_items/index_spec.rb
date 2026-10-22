RSpec.describe "GET /admin/magic_items" do
  subject { get admin_magic_items_path }

  let(:admin) { create(:admin_user) }

  before do
    create(:magic_item)
    sign_in(admin)
  end

  it { is_expected.to eq(200) }
end
