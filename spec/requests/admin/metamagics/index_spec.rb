RSpec.describe "GET /admin/metamagics" do
  subject { get admin_metamagics_path }

  let(:admin) { create(:admin_user) }

  before do
    create(:metamagic)
    sign_in(admin)
  end

  it { is_expected.to eq(200) }
end
