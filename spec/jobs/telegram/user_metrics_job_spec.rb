RSpec.describe Telegram::UserMetricsJob do
  subject { described_class.perform_now(payload) }

  let(:payload) do
    {}
  end

  around do |example|
    Timecop.freeze(Time.current.beginning_of_hour) do
      example.run
    end
  end

  it "does nothing" do
    expect { subject }.not_to change { TelegramUser.count }
  end

  context "when payload is not empty" do
    let(:payload) do
      {
        "message_id" => 467,
        "from" => {
          "id" => external_user_id,
          "is_bot" => false,
          "first_name" => "FirstName",
          "last_name" => "LastName",
          "username" => "UserName",
          "language_code" => "en"
        },
        "chat" => {
          "id" => 1350564680,
          "first_name" => "FirstName",
          "last_name" => "LastName",
          "username" => "UserName",
          "type" => "private"
        },
        "date" => date.to_i,
        "text" => "1"
      }
    end
    let(:external_user_id) { 1350564680 }
    let(:date) { Time.current - 1.month }

    it "creates new user with proper attributes" do
      expect { subject }.to change { TelegramUser.count }.from(0).to(1)
      expect(TelegramUser.last).to have_attributes(
        last_seen_at: date,
        username: "UserName",
        chat_id: 1350564680
      )
    end

    context "when uses has has already been created" do
      let!(:user) do
        create(
          :telegram_user,
          username: "previous_username",
          chat_id: 123123,
          external_id: external_user_id,
          command_requested_count: 13,
          last_seen_at: last_seen_at
        )
      end
      let(:last_seen_at) { Time.current - 100.years }

      it "updates counter" do
        expect { subject }.to change { user.reload.command_requested_count }.from(13).to(14)
      end

      it "updates last_seen_at" do
        expect { subject }.to change { user.reload.last_seen_at }.from(last_seen_at).to(date)
      end

      context "when last_seen_at is in the future" do
        let(:last_seen_at) { Time.current + 1.month }

        it "updates counter" do
          expect { subject }.to change { user.reload.command_requested_count }.from(13).to(14)
        end

        it "does not update last_seen_at" do
          expect { subject }.not_to change { user.reload.last_seen_at }
        end
      end

      context "when previous username differs from current username" do
        it "changes username" do
          expect { subject }.to change { user.reload.username }.from("previous_username").to("UserName")
        end

        context "when user currently hided theirs name" do
          let(:payload) do
            super().deep_dup.tap do |hash|
              hash["from"]["username"] = nil
            end
          end

          it "changes username" do
            expect { subject }.not_to change { user.reload.username }
          end
        end
      end

      context "when previous chat_id differs from current chat_id" do
        it "changes chat_id" do
          expect { subject }.to change { user.reload.chat_id }.from(123123).to(1350564680)
        end
      end
    end
  end
end
