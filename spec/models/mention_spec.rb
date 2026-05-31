require "rails_helper"

RSpec.describe Mention do
  describe "associations" do
    it "belongs to a polymorphic mentionable" do
      reflection = described_class.reflect_on_association(:mentionable)

      expect(reflection.macro).to eq(:belongs_to)
      expect(reflection.options[:polymorphic]).to be(true)
    end

    it "belongs to a polymorphic another_mentionable" do
      reflection = described_class.reflect_on_association(:another_mentionable)

      expect(reflection.macro).to eq(:belongs_to)
      expect(reflection.options[:polymorphic]).to be(true)
    end
  end

  describe "persistence" do
    subject(:mention) { build(:mention) }

    it { is_expected.to be_valid }

    it "links two mentionable records" do
      mention.save!

      expect(mention.mentionable).to be_present
      expect(mention.another_mentionable).to be_present
    end
  end
end
