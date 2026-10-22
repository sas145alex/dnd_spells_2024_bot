RSpec.describe "GET /admin/feedbacks" do
  subject { get admin_feedbacks_path }

  let(:admin) { create(:admin_user) }

  before do
    create(:feedback)
    sign_in(admin)
  end

  it { is_expected.to eq(200) }
end
