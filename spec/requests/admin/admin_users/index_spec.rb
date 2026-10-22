RSpec.describe "GET /admin/admin_users" do
  subject { get admin_admin_users_path }

  let(:admin) { create(:admin_user) }

  before do
    create(:admin_user)
    sign_in(admin)
  end

  it { is_expected.to eq(200) }
end
