RSpec.describe "GET /admin/psionic_powers" do
  subject { get admin_psionic_powers_path }

  let(:admin) { create(:admin_user) }

  before do
    create(:psionic_power)
    sign_in(admin)
  end

  it { is_expected.to eq(200) }
end
