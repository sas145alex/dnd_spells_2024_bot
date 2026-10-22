RSpec.describe "GET /admin/mentions" do
  subject { get admin_mentions_path }

  let(:admin) { create(:admin_user) }

  before do
    create(:mention)
    sign_in(admin)
  end

  it { is_expected.to eq(200) }
end
