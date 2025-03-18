RSpec.describe Feedback::NotificationJob do
  subject(:perform) { described_class.perform_now(feedback_id) }

  let(:feedback_id) { feedback.id }
  let(:feedback) { create(:feedback) }

  let(:service) { Feedback::Notificator }

  before do
    allow(service).to receive(:call)
  end

  it "calls proper service" do
    perform
    expect(service).to have_received(:call).with(feedback)
  end
end
