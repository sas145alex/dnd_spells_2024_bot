RSpec.describe "GET /admin/origins" do
  subject { get admin_origins_path }

  let(:admin) { create(:admin_user) }

  before do
    create(:origin)
    sign_in(admin)
  end

  it { is_expected.to eq(200) }
end
