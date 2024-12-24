class TelegramChat
  class MarkAsRemoved < ApplicationOperation
    def initialize(bot:, chat_id:)
      @bot = bot
      @chat_id = chat_id
    end

    def call
      chat = TelegramChat.find_or_create_by!(external_id: chat_id) do |new_chat|
        new_chat.last_seen_at = Time.current
        new_chat.bot_added_at = Time.current
      end
      chat.update!(bot_removed_at: Time.current)
    end

    private

    attr_reader :bot
    attr_reader :chat_id
  end
end
