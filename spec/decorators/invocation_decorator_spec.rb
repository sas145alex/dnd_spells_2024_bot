require "rails_helper"

RSpec.describe InvocationDecorator do
  describe "#title" do
    subject(:title) { invocation.decorate.title }

    let(:invocation) { build(:invocation, level: level, title: "Взор дьявола") }
    let(:level) { 2 }

    it { is_expected.to eq("[2] Взор дьявола") }

    context "with a different level" do
      let(:level) { 9 }

      it { is_expected.to eq("[9] Взор дьявола") }
    end
  end

  describe "#description_for_telegram" do
    subject(:description) { invocation.decorate.description_for_telegram }

    let(:invocation) { build(:invocation, description: raw_description) }
    let(:raw_description) { "**Hello**" }

    it { is_expected.to eq(FormatChanger.markdown_to_telegram_markdown(raw_description).strip) }

    context "when the description is blank" do
      let(:raw_description) { "" }

      it { is_expected.to be_nil }
    end
  end

  describe "#global_search_title" do
    subject(:global_search_title) { invocation.decorate.global_search_title }

    let(:invocation) { build(:invocation, level: 1, title: "взор") }

    it { is_expected.to eq("[#{Invocation.model_name.human}] #{invocation.decorate.title.capitalize}") }
  end

  describe "#parse_mode_for_telegram" do
    subject(:parse_mode) { invocation.decorate.parse_mode_for_telegram }

    let(:invocation) { build(:invocation) }

    it { is_expected.to eq("HTML") }
  end
end
