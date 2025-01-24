class TelegramUser
  class MarkAsRemoved < ApplicationOperation
    def initialize(bot:, chat_id:)
      @bot = bot
      @chat_id = chat_id
    end

    def call
      user = TelegramUser.find_or_create_by!(external_id: chat_id) do |new_user|
        new_user.last_seen_at = Time.current
      end
      user.update!(bot_removed_at: Time.current)
    end

    private

    attr_reader :bot
    attr_reader :chat_id
  end
end
