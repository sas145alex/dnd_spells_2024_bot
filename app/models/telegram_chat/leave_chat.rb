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
    end

    private

    attr_reader :bot
    attr_reader :chat_id
  end
end
