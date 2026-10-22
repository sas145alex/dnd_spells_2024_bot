RSpec.describe "GET /admin/creatures" do
  subject { get admin_creatures_path }

  let(:admin) { create(:admin_user) }

  before do
    create(:creature)
    sign_in(admin)
  end

  it { is_expected.to eq(200) }
end
