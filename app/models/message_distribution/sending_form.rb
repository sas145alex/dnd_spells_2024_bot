class MessageDistribution
  # Backs the "prepare sending" admin form. Provides default values only — the
  # chosen segment is persisted onto the MessageDistribution on submit.
  class SendingForm < ApplicationForm
    def send_to_users
      true
    end

    def send_to_chats
      false
    end

    def only_active
      true
    end

    def active_since
      60.days.ago
    end

    def min_command_count
      nil
    end

    def test_sending
      false
    end

    def test_telegram_user_ids
      []
    end

    def test_telegram_chat_ids
      ""
    end
  end
end
