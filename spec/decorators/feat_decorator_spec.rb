require "rails_helper"

RSpec.describe FeatDecorator do
  describe "#title" do
    subject(:title) { feat.decorate.title }

    let(:feat) { build(:feat, title: feat_title, original_title: original_title) }
    let(:feat_title) { "Меткий стрелок" }
    let(:original_title) { "Sharpshooter" }

    it { is_expected.to eq("Меткий стрелок [Sharpshooter]") }

    context "without an original title" do
      let(:original_title) { nil }

      it { is_expected.to eq("Меткий стрелок") }
    end

    context "without a title" do
      let(:feat_title) { "" }

      it { is_expected.to eq(" [Sharpshooter]") }
    end
  end

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

  describe "#global_search_title" do
    subject(:global_search_title) { feat.decorate.global_search_title }

    let(:feat) { build(:feat, title: "меткий стрелок", original_title: "Sharpshooter") }

    it "uses the raw object title rather than the decorated one" do
      expect(global_search_title).to eq("[#{Feat.model_name.human}] #{feat.title.capitalize}")
    end
  end

  describe "#parse_mode_for_telegram" do
    subject(:parse_mode) { feat.decorate.parse_mode_for_telegram }

    let(:feat) { build(:feat) }

    it { is_expected.to eq("HTML") }
  end
end
