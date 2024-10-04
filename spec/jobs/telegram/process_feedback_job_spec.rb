RSpec.describe Telegram::ProcessFeedbackJob do
  subject(:perform) { described_class.perform_now(text, from: from, message_time: message_time) }

  around do |example|
    Timecop.freeze(Time.parse("2024-10-30")) do
      example.run
    end
  end

  let(:text) { "text" }
  let(:from) do
    {
      "id" => 123,
      "first_name" => "John",
      "last_name" => "Smith",
      "username" => "johnsmith"
    }
  end
  let(:message_time) { Time.now.to_i }

  before do
    allow(Feedback).to receive(:create)
  end

  it "creates advice" do
    perform

    expect(Feedback).to have_received(:create).with(
      text: text,
      author: "ID: 123 - John - Smith - johnsmith",
      timestamp: Time.at(message_time)
    )
  end
end
