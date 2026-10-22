RSpec.describe "GET /admin/bastions" do
  subject { get admin_bastions_path }

  let(:admin) { create(:admin_user) }

  before do
    create(:bastion)
    sign_in(admin)
  end

  it { is_expected.to eq(200) }
end
