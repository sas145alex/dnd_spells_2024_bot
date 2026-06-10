require "rails_helper"

RSpec.describe BastionDecorator do
  describe "#description_for_telegram" do
    subject(:description_for_telegram) { bastion.decorate.description_for_telegram }

    let(:bastion) { build(:bastion, title: "Спальня", description: raw_description) }
    let(:raw_description) { "**Привет**" }

    it "wraps the title and rendered body" do
      body = FormatChanger.markdown_to_telegram_markdown(raw_description).strip
      expect(description_for_telegram).to eq("<b>Спальня</b>\n\n#{body}")
    end

    context "without a description" do
      let(:raw_description) { "" }

      it { is_expected.to be_nil }
    end
  end

  describe "#original_description_for_telegram" do
    subject(:original_description_for_telegram) { bastion.decorate.original_description_for_telegram }

    let(:bastion) { build(:bastion, original_title: "Bedroom", original_description: raw_description) }
    let(:raw_description) { "**Hello**" }

    it "wraps the original title and rendered body" do
      body = FormatChanger.markdown_to_telegram_markdown(raw_description).strip
      expect(original_description_for_telegram).to eq("<b>Bedroom</b>\n\n#{body}")
    end

    context "without an original description" do
      let(:raw_description) { "" }

      it { is_expected.to be_nil }
    end
  end
end
