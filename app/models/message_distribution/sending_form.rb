class MessageDistribution
  class SendingForm < ApplicationForm
    def telegram_user_ids
      []
    end

    def active_since
      Time.current - 90.days
    end

    def test_sending
      false
    end
  end
end
