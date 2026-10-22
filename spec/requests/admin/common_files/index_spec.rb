RSpec.describe "GET /admin/common_files" do
  subject { get admin_common_files_path }

  let(:admin) { create(:admin_user) }

  before do
    create(:common_file)
    sign_in(admin)
  end

  it { is_expected.to eq(200) }
end
