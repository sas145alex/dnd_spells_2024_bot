RSpec.describe Feedback do
  describe "#notify_later" do
    subject(:notify) { feedback.notify_later }

    let(:feedback) { build(:feedback, id: 123) }
    let(:notification_job) { Feedback::NotificationJob }

    before do
      allow(notification_job).to receive(:perform_later)
    end

    it "calls proper job" do
      expect(notify).not_to eq(false)

      expect(notification_job).to have_received(:perform_later).with(feedback.id)
    end

    context "when feedback record has not been saved" do
      let(:feedback) { build(:feedback, id: nil) }

      it "does not call notification job" do
        expect(notify).to eq(false)

        expect(notification_job).not_to have_received(:perform_later)
      end
    end
  end
end
