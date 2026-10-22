RSpec.describe "GET /admin/spells" do
  subject { get admin_spells_path }

  let(:admin) { create(:admin_user) }

  before do
    create(:spell)
    sign_in(admin)
  end

  it { is_expected.to eq(200) }
end
