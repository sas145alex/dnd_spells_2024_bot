RSpec.describe "GET /admin/character_klass_abilities" do
  subject { get admin_character_klass_abilities_path }

  let(:admin) { create(:admin_user) }

  before do
    create(:character_klass_ability)
    sign_in(admin)
  end

  it { is_expected.to eq(200) }
end
