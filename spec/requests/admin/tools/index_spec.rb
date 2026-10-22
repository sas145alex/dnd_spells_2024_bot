RSpec.describe "GET /admin/tools" do
  subject { get admin_tools_path }

  let(:admin) { create(:admin_user) }

  before do
    create(:tool)
    sign_in(admin)
  end

  it { is_expected.to eq(200) }
end
