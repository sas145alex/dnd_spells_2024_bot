RSpec.describe BotCommands::Error do
  subject(:trigger) { described_class.call(user: user, input_value: input_value) }

  let(:user) { create(:telegram_user) }
  let(:input_value) { nil }

  context "when the user is not an admin" do
    it { is_expected.to eq([]) }

    it "does not raise" do
      expect { trigger }.not_to raise_error
    end
  end

  context "when the user is nil" do
    let(:user) { nil }

    it { is_expected.to eq([]) }
  end

  context "when the user is an admin" do
    let(:user) { create(:telegram_user, :admin) }

    context "with custom text" do
      let(:input_value) { "boom" }

      it "raises the test error with the given message" do
        expect { trigger }.to raise_error(described_class::TestError, "boom")
      end
    end

    context "with blank text" do
      let(:input_value) { "" }

      it "raises the test error with the default message" do
        expect { trigger }.to raise_error(described_class::TestError, described_class::DEFAULT_MESSAGE)
      end
    end
  end
end
