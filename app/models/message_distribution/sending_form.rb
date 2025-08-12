class MessageDistribution
  class SendingForm < ApplicationForm
    def telegram_user_ids
      []
    end

    def telegram_chat_ids
      []
    end

    def active_since
      60.days.ago
    end

    def test_sending
      false
    end

    def send_to_users
      true
    end

    def send_to_chats
      true
    end
  end
end
