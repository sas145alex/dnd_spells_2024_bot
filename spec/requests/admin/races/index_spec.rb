RSpec.describe "GET /admin/races" do
  subject { get admin_races_path }

  let(:admin) { create(:admin_user) }

  before do
    create(:race)
    sign_in(admin)
  end

  it { is_expected.to eq(200) }
end
