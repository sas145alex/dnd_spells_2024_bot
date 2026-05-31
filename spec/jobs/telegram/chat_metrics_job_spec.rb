require "rails_helper"

RSpec.describe Telegram::ChatMetricsJob do
  subject { described_class.perform_now(payload, chat) }

  let(:payload) { {} }
  let(:chat) { {} }

  around do |example|
    Timecop.freeze(Time.current.beginning_of_hour) do
      example.run
    end
  end

  context "when chat has no id" do
    it "does nothing" do
      expect { subject }.not_to change { TelegramChat.count }
    end
  end

  context "when chat id is present" do
    let(:external_chat_id) { -1001350564680 }
    let(:date) { 1.month.ago }
    let(:payload) { {"date" => date.to_i} }
    let(:chat) { {"id" => external_chat_id, "type" => "supergroup"} }

    context "when the chat does not exist yet" do
      it "creates a new chat" do
        expect { subject }.to change { TelegramChat.count }.from(0).to(1)
      end

      it "sets attributes" do
        subject

        expect(TelegramChat.last).to have_attributes(
          external_id: external_chat_id,
          command_requested_count: 1,
          last_seen_at: date,
          bot_added_at: Time.current
        )
      end
    end

    context "when the chat already exists" do
      let!(:existing_chat) do
        create(
          :telegram_chat,
          external_id: external_chat_id,
          command_requested_count: 7,
          last_seen_at: last_seen_at,
          bot_removed_at: bot_removed_at
        )
      end
      let(:last_seen_at) { 100.years.ago }
      let(:bot_removed_at) { nil }

      it "increments the counter" do
        expect { subject }.to change { existing_chat.reload.command_requested_count }.from(7).to(8)
      end

      it "updates last_seen_at" do
        expect { subject }.to change { existing_chat.reload.last_seen_at }.from(last_seen_at).to(date)
      end

      context "when last_seen_at is in the future" do
        let(:last_seen_at) { 1.month.from_now }

        it "does not move last_seen_at backwards" do
          expect { subject }.not_to change { existing_chat.reload.last_seen_at }
        end
      end

      context "when the bot was removed before this message" do
        let(:bot_removed_at) { 2.months.ago }

        it "clears bot_removed_at" do
          expect { subject }.to change { existing_chat.reload.bot_removed_at }.from(bot_removed_at).to(nil)
        end
      end

      context "when the bot was removed after this message" do
        let(:bot_removed_at) { 1.day.ago }

        it "keeps bot_removed_at" do
          expect { subject }.not_to change { existing_chat.reload.bot_removed_at }
        end
      end
    end

    context "when the payload has no date" do
      let(:payload) { {} }

      it "uses the current time as last_seen_at" do
        subject

        expect(TelegramChat.last.last_seen_at).to eq(Time.current)
      end
    end
  end
end
