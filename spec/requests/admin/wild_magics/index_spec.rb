RSpec.describe "GET /admin/wild_magics" do
  subject { get admin_wild_magics_path }

  let(:admin) { create(:admin_user) }

  before do
    create(:wild_magic)
    sign_in(admin)
  end

  it { is_expected.to eq(200) }
end
