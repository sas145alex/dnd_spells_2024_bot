class MessageDistribution
  # Synchronous preview send to a small list of Telegram chat ids. The ids may be
  # user external ids or chat external ids — both are just a chat_id for the Bot
  # API. Does not create MessageDelivery rows and does not change the status.
  class TestSend < ApplicationOperation
    def initialize(distribution:, chat_ids:)
      @distribution = distribution
      @chat_ids = Array(chat_ids).compact_blank.map(&:to_i)
    end

    def call
      return false if chat_ids.empty?

      chat_ids.each { |chat_id| send_to(chat_id) }
      true
    end

    private

    attr_reader :distribution, :chat_ids

    def send_to(chat_id)
      Telegram.bot.async(false) do
        Telegram.bot.send_message(
          chat_id: chat_id,
          text: distribution.telegram_text,
          parse_mode: "HTML"
        )
      end
    rescue Telegram::Bot::Error => e
      Rails.logger.error(e)
      nil
    end
  end
end
