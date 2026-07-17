# Shared example for the Favoritable concern (app/models/concerns/favoritable.rb).
#
# Invoked for every model by the "multisearchable" shared example (Multisearchable includes
# Favoritable), so a model spec needs it directly only if the model is favoritable but not
# searchable.
#
# Verifies the polymorphic `favorites` association the concern declares and that
# a record can be favorited by a TelegramUser.
RSpec.shared_examples "favoritable" do |factory_name|
  describe "Favoritable" do
    subject(:record) { create(factory_name) }

    it "has a polymorphic :favorites association" do
      reflection = described_class.reflect_on_association(:favorites)

      expect(reflection.macro).to eq(:has_many)
      expect(reflection.options[:as]).to eq(:favoritable)
      expect(reflection.options[:dependent]).to eq(:destroy)
    end

    it "can be favorited by a telegram user" do
      user = create(:telegram_user)
      favorite = Favorite.create!(telegram_user: user, favoritable: record)

      expect(record.favorites).to include(favorite)
      expect(user).to be_favorited(record)
    end
  end
end
