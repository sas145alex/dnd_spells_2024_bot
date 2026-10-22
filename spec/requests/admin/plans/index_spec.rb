RSpec.describe "GET /admin/plans" do
  subject { get admin_plans_path }

  let(:admin) { create(:admin_user) }

  before do
    create(:plan)
    sign_in(admin)
  end

  it { is_expected.to eq(200) }
end
