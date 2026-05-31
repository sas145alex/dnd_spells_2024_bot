require "rails_helper"

RSpec.describe RollFormula do
  describe "#valid?" do
    subject(:valid) { described_class.new(formula).valid? }

    let(:formula) { "2d20" }

    it { is_expected.to be(true) }

    context "with a simple dice and modifier" do
      let(:formula) { "1d6+3" }

      it { is_expected.to be(true) }
    end

    context "with a blank formula" do
      let(:formula) { "" }

      it { is_expected.to be(false) }
    end

    context "with zero dice" do
      let(:formula) { "0d6" }

      it { is_expected.to be(false) }
    end

    context "with too many dice" do
      let(:formula) { "200d6" }

      it { is_expected.to be(false) }
    end

    context "with a dice value above the maximum" do
      let(:formula) { "2d200" }

      it { is_expected.to be(false) }
    end

    context "with a modifier above the maximum" do
      let(:formula) { "1d6+20000" }

      it { is_expected.to be(false) }
    end
  end

  describe "#invalid?" do
    subject(:invalid) { described_class.new(formula).invalid? }

    let(:formula) { "2d20" }

    it { is_expected.to be(false) }

    context "with a blank formula" do
      let(:formula) { "" }

      it { is_expected.to be(true) }
    end
  end

  describe "#rolls_sum_total" do
    subject(:total) { formula.rolls_sum_total }

    let(:formula) { described_class.new(input) }
    let(:input) { "2d6" }

    before { allow(formula).to receive(:rand).and_return(4) }

    it { is_expected.to eq(8) }

    context "with a positive modifier" do
      let(:input) { "2d6+3" }

      it { is_expected.to eq(11) }
    end

    context "with a negative modifier" do
      let(:input) { "2d6-2" }

      it { is_expected.to eq(6) }
    end
  end
end
