RSpec.describe "GET /admin/maneuvers" do
  subject { get admin_maneuvers_path }

  let(:admin) { create(:admin_user) }

  before do
    create(:maneuver)
    sign_in(admin)
  end

  it { is_expected.to eq(200) }
end
