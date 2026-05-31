require "rails_helper"

RSpec.describe CommonFile do
  describe "validations" do
    subject(:record) { build(:common_file, title: title) }

    let(:title) { "Reference sheet" }

    it { is_expected.to be_valid }

    context "without a title" do
      let(:title) { nil }

      it { is_expected.not_to be_valid }
    end

    context "without an attachment" do
      subject(:record) do
        build(:common_file, title: title).tap { |f| f.attachment.detach }
      end

      it { is_expected.not_to be_valid }
    end
  end

  describe "attachment" do
    subject(:record) { create(:common_file) }

    it { expect(record.attachment).to be_attached }
  end
end
