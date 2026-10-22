RSpec.describe "GET /admin/invocations" do
  subject { get admin_invocations_path }

  let(:admin) { create(:admin_user) }

  before do
    create(:invocation)
    sign_in(admin)
  end

  it { is_expected.to eq(200) }
end
