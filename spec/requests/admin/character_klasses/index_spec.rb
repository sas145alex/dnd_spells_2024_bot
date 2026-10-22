RSpec.describe "GET /admin/character_klasses" do
  subject { get admin_character_klasses_path }

  let(:admin) { create(:admin_user) }

  before do
    create(:character_klass)
    sign_in(admin)
  end

  it { is_expected.to eq(200) }
end
