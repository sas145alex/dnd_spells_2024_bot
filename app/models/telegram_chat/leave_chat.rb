class TelegramChat
  class LeaveChat < ApplicationOperation
    def initialize(bot:, chat_id:)
      @bot = bot
      @chat_id = chat_id
    end

    def call
      client_class = BotRequestJob.client_class
      client = client_class.wrap(bot.id)
      client.async(false) do
        bot.send_message(chat_id: chat_id, text: "Не назначай меня администратором")
        bot.leave_chat(chat_id: chat_id)
      end
    rescue Telegram::Bot::Error => e
      # Expected Telegram states when leaving: admin rights revoked ("need administrator
      # rights in the channel chat"), bot already removed (Forbidden/NotFound), etc. The
      # chat is already gone or inaccessible, so treat it as a no-op instead of letting the
      # synchronous webhook send 500 and trigger redelivery.
      Rails.logger.info("TelegramChat::LeaveChat skipped for chat #{chat_id}: #{e.message}")
      nil
    end

    private

    attr_reader :bot
    attr_reader :chat_id
  end
end
