RSpec.describe "Admin message distribution sending" do
  let(:admin) { create(:admin_user) }
  let(:distribution) { create(:message_distribution) }

  before { sign_in(admin) }

  describe "POST submit_sending (real send)" do
    subject(:submit) do
      post submit_sending_admin_message_distribution_path(distribution),
        params: {message_distribution_sending_form: form}
    end

    let(:form) do
      {
        send_to_users: "1",
        send_to_chats: "0",
        only_active: "1",
        active_since: "",
        min_command_count: "",
        test_sending: "0"
      }
    end

    let!(:user) { create(:telegram_user) }

    before { allow(MessageDistribution::DeliveryJob).to receive(:perform_later) }

    it "persists the segment, enqueues delivery, and redirects" do
      submit

      expect(distribution.reload.send_to_chats).to be(false)
      expect(distribution).to be_queued
      expect(MessageDistribution::DeliveryJob).to have_received(:perform_later)
      expect(response).to redirect_to(admin_message_distribution_path(distribution))
    end
  end

  describe "POST submit_sending (test send)" do
    subject(:submit) do
      post submit_sending_admin_message_distribution_path(distribution),
        params: {message_distribution_sending_form: {
          test_sending: "1",
          test_telegram_user_ids: ["555"],
          test_telegram_chat_ids: "-100777"
        }}
    end

    before { allow(Telegram.bot).to receive(:send_message) }

    it "sends a test message to users and chats without changing status" do
      submit

      expect(Telegram.bot).to have_received(:send_message).with(hash_including(chat_id: 555))
      expect(Telegram.bot).to have_received(:send_message).with(hash_including(chat_id: -100777))
      expect(distribution.reload).to be_draft
    end
  end

  describe "GET message_deliveries index" do
    subject(:index) { get admin_message_deliveries_path(q: {message_distribution_id_eq: distribution.id}) }

    let!(:delivery) { create(:message_delivery, :sent, message_distribution: distribution) }

    it "renders the deliveries for the distribution" do
      index

      expect(response).to have_http_status(:ok)
    end
  end
end
