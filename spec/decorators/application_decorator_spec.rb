require "rails_helper"

RSpec.describe ApplicationDecorator do
  describe "#description_for_telegram" do
    subject(:description) { feat.decorate.description_for_telegram }

    let(:feat) { build(:feat, description: raw_description) }
    let(:raw_description) { "**Hello**" }

    it { is_expected.to eq(FormatChanger.markdown_to_telegram_markdown(raw_description).strip) }

    context "when the description is blank" do
      let(:raw_description) { "" }

      it { is_expected.to be_nil }
    end
  end

  describe "#parse_mode_for_telegram" do
    subject(:parse_mode) { feat.decorate.parse_mode_for_telegram }

    let(:feat) { build(:feat) }

    it { is_expected.to eq("HTML") }
  end

  describe "#global_search_title" do
    subject(:global_search_title) { feat.decorate.global_search_title }

    let(:feat) { build(:feat, title: "боец") }

    it { is_expected.to eq("[#{Feat.model_name.human}] #{feat.decorate.title.capitalize}") }
  end

  describe "#support_other_languages?" do
    subject(:support_other_languages) { creature.decorate.support_other_languages? }

    let(:creature) { build(:creature, description: description, original_description: original_description) }
    let(:description) { "**Описание**" }
    let(:original_description) { "**Description**" }

    it { is_expected.to be(true) }

    context "when the original description is blank" do
      let(:original_description) { "" }

      it { is_expected.to be_falsey }
    end

    context "when the description is blank" do
      let(:description) { "" }

      it { is_expected.to be_falsey }
    end
  end
end
