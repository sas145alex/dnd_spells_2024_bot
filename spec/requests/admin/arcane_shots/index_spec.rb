RSpec.describe "GET /admin/arcane_shots" do
  subject { get admin_arcane_shots_path }

  let(:admin) { create(:admin_user) }

  before do
    create(:arcane_shot)
    sign_in(admin)
  end

  it { is_expected.to eq(200) }
end
