class TelegramChat
  class MarkAsAdded < ApplicationOperation
    def initialize(bot:, chat_id:)
      @bot = bot
      @chat_id = chat_id
    end

    def call
      chat = TelegramChat.find_or_create_by!(external_id: chat_id) do |new_chat|
        new_chat.last_seen_at = Time.current
      end
      chat.update!(bot_added_at: Time.current, bot_removed_at: nil)
    end

    private

    attr_reader :bot
    attr_reader :chat_id
  end
end
