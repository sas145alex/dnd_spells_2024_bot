require "rails_helper"

RSpec.describe BotCommand do
  it_behaves_like "mentionable", :bot_command

  describe "validations" do
    subject(:record) { build(:bot_command, title: title) }

    let(:title) { "custom_command" }

    it { is_expected.to be_valid }

    context "without a title" do
      let(:title) { nil }

      it { is_expected.not_to be_valid }
    end

    context "with a too-short title" do
      let(:title) { "ab" }

      it { is_expected.not_to be_valid }
    end

    context "with a duplicate title" do
      before { create(:bot_command, title: "duplicate_one") }

      let(:title) { "duplicate_one" }

      it { is_expected.not_to be_valid }
    end
  end

  describe "#strip_title" do
    subject(:record) { create(:bot_command, title: "  padded  ") }

    it { expect(record.title).to eq("padded") }
  end

  describe ".ordered" do
    subject { described_class.ordered.where(id: [first.id, second.id]) }

    let!(:second) { create(:bot_command, title: "zz_b_command") }
    let!(:first) { create(:bot_command, title: "aa_a_command") }

    it { is_expected.to eq([first, second]) }
  end

  describe "memoized lookups" do
    around do |example|
      described_class._reset_memoized_commands
      example.run
      described_class._reset_memoized_commands
    end

    describe "._memoized_commands" do
      it "memoizes the loaded command list" do
        record = create(:bot_command, title: "memoized_one")

        expect(described_class._memoized_commands).to include(record)
      end

      it "does not reload after the first call" do
        described_class._memoized_commands
        create(:bot_command, title: "added_later")

        expect(described_class._memoized_commands.map(&:title)).not_to include("added_later")
      end
    end

    describe ".memoized_search" do
      it "finds a command by title" do
        record = create(:bot_command, title: "searchable_command")

        expect(described_class.memoized_search(title: "searchable_command")).to eq(record)
      end
    end

    describe "named lookups" do
      let!(:start_command) do
        described_class.find_or_create_by!(title: described_class::START_ID)
      end
      let!(:about_command) do
        described_class.find_or_create_by!(title: described_class::ABOUT_ID)
      end

      it ".start finds the start command" do
        expect(described_class.start).to eq(start_command)
      end

      it ".about finds the about command" do
        expect(described_class.about).to eq(about_command)
      end
    end

    describe "._reset_memoized_commands" do
      it "forces a reload on the next call" do
        described_class._memoized_commands
        record = create(:bot_command, title: "after_reset")
        described_class._reset_memoized_commands

        expect(described_class._memoized_commands).to include(record)
      end
    end
  end
end
