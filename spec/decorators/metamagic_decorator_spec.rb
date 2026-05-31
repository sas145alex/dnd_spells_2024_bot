require "rails_helper"

RSpec.describe MetamagicDecorator do
  describe "#title" do
    subject(:title) { metamagic.decorate.title }

    let(:metamagic) { build(:metamagic, sorcery_points: sorcery_points, title: "Тонкое заклинание") }
    let(:sorcery_points) { 1 }

    it { is_expected.to eq("[1] Тонкое заклинание") }

    context "with a different sorcery points cost" do
      let(:sorcery_points) { 3 }

      it { is_expected.to eq("[3] Тонкое заклинание") }
    end
  end

  describe "#description_for_telegram" do
    subject(:description) { metamagic.decorate.description_for_telegram }

    let(:metamagic) { build(:metamagic, description: raw_description) }
    let(:raw_description) { "**Hello**" }

    it { is_expected.to eq(FormatChanger.markdown_to_telegram_markdown(raw_description).strip) }

    context "when the description is blank" do
      let(:raw_description) { "" }

      it { is_expected.to be_nil }
    end
  end

  describe "#global_search_title" do
    subject(:global_search_title) { metamagic.decorate.global_search_title }

    let(:metamagic) { build(:metamagic, sorcery_points: 1, title: "тонкое заклинание") }

    it { is_expected.to eq("[#{Metamagic.model_name.human}] #{metamagic.decorate.title.capitalize}") }
  end

  describe "#parse_mode_for_telegram" do
    subject(:parse_mode) { metamagic.decorate.parse_mode_for_telegram }

    let(:metamagic) { build(:metamagic) }

    it { is_expected.to eq("HTML") }
  end
end
