require "rails_helper"

RSpec.describe EquipmentItemDecorator do
  describe "#title" do
    subject(:title) { equipment_item.decorate.title }

    let(:equipment_item) { build(:equipment_item, title: "Верёвка") }

    it { is_expected.to eq("Верёвка") }
  end

  describe "#description_for_telegram" do
    subject(:description) { equipment_item.decorate.description_for_telegram }

    let(:equipment_item) { build(:equipment_item, description: raw_description) }
    let(:raw_description) { "**Hello**" }

    it { is_expected.to eq(FormatChanger.markdown_to_telegram_markdown(raw_description).strip) }

    context "when the description is blank" do
      let(:raw_description) { "" }

      it { is_expected.to be_nil }
    end
  end

  describe "#global_search_title" do
    subject(:global_search_title) { equipment_item.decorate.global_search_title }

    let(:equipment_item) { build(:equipment_item, title: "верёвка") }

    it { is_expected.to eq("[#{EquipmentItem.model_name.human}] #{equipment_item.decorate.title.capitalize}") }
  end

  describe "#parse_mode_for_telegram" do
    subject(:parse_mode) { equipment_item.decorate.parse_mode_for_telegram }

    let(:equipment_item) { build(:equipment_item) }

    it { is_expected.to eq("HTML") }
  end
end
