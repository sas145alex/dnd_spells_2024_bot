RSpec.describe Telegram::ProcessFeedbackJob do
  subject(:perform) { described_class.perform_now(payload) }

  around do |example|
    Timecop.freeze(Time.parse("2024-10-30")) do
      example.run
    end
  end

  let(:payload) do
    {
      "message_id" => 467,
      "from" => from,
      "chat" => chat,
      "date" => message_time,
      "text" => text
    }
  end

  let(:from) do
    {
      "id" => 123,
      "first_name" => "John",
      "last_name" => "Smith",
      "username" => "johnsmith"
    }
  end
  let(:chat) do
    {
      "id" => 1350564680,
      "first_name" => "FirstName",
      "last_name" => "LastName",
      "username" => "UserName",
      "type" => "private"
    }
  end
  let(:message_time) { Time.now.to_i }
  let(:text) { "text" }

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
