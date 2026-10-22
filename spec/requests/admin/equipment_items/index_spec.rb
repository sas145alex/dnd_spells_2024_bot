RSpec.describe "GET /admin/equipment_items" do
  subject { get admin_equipment_items_path }

  let(:admin) { create(:admin_user) }

  before do
    create(:equipment_item)
    sign_in(admin)
  end

  it { is_expected.to eq(200) }
end
