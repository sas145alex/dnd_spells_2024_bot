RSpec.describe "GET /admin/message_distributions" do
  subject { get admin_message_distributions_path }

  let(:admin) { create(:admin_user) }

  before do
    create(:message_distribution)
    sign_in(admin)
  end

  it { is_expected.to eq(200) }
end
