RSpec.describe "GET /admin/telegram_users" do
  subject { get admin_telegram_users_path }

  let(:admin) { create(:admin_user) }

  before do
    create(:favorite)
    sign_in(admin)
  end

  it { is_expected.to eq(200) }
end
