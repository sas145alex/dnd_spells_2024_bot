RSpec.describe "GET /admin/feats" do
  subject { get admin_feats_path }

  let(:admin) { create(:admin_user) }

  before do
    create(:feat)
    sign_in(admin)
  end

  it { is_expected.to eq(200) }
end
