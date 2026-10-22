RSpec.describe "GET /admin/characteristics" do
  subject { get admin_characteristics_path }

  let(:admin) { create(:admin_user) }

  before do
    create(:characteristic)
    sign_in(admin)
  end

  it { is_expected.to eq(200) }
end
