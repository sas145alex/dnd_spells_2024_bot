RSpec.describe "GET /admin/bot_commands" do
  subject { get admin_bot_commands_path }

  let(:admin) { create(:admin_user) }

  before do
    create(:bot_command)
    sign_in(admin)
  end

  it { is_expected.to eq(200) }
end
