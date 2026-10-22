RSpec.describe "GET /admin/telegram_chats" do
  subject { get admin_telegram_chats_path }

  let(:admin) { create(:admin_user) }

  before do
    create(:telegram_chat)
    sign_in(admin)
  end

  it { is_expected.to eq(200) }
end
