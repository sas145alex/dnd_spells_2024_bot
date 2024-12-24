class TelegramChat
  class MemberChangeProcessor < ApplicationOperation
    def initialize(bot:, payload:, chat_id:)
      @bot = bot
      @payload = payload
      @chat_id = chat_id
    end

    # bot added to a chat
    # {"chat"=>{"id"=>-4772963005, "title"=>"chat with test bot", "type"=>"group", "all_members_are_administrators"=>true},
    #  "from"=>{"id"=>350564680, "is_bot"=>false, "first_name"=>"some_first_name", "last_name"=>"some_last_name", "username"=>"some_username", "language_code"=>"en"},
    #  "date"=>1734539200,
    #  "old_chat_member"=>{"user"=>{"id"=>7412437273, "is_bot"=>true, "first_name"=>"dnd_spells_2024_dev", "username"=>"dnd_spells_2024_dev_bot"}, "status"=>"member"},
    #  "new_chat_member"=>{"user"=>{"id"=>7412437273, "is_bot"=>true, "first_name"=>"dnd_spells_2024_dev", "username"=>"dnd_spells_2024_dev_bot"}, "status"=>"left"}}
    def call
      return unless current_bot_affected?

      if current_bot_added?
        add_bot_to_chat
      elsif current_bot_removed?
        remove_bot_from_chat
      elsif bot_administrator_granted?
        leave_chat!
        remove_bot_from_chat
      elsif bot_restricted?
        nil
      else
        send_error_to_sentry
      end
    end

    private

    attr_reader :bot
    attr_reader :payload
    attr_reader :chat_id

    def add_bot_to_chat
      TelegramChat::MarkAsAdded.call(bot: bot, chat_id: external_chat_id)
    end

    def remove_bot_from_chat
      TelegramChat::MarkAsRemoved.call(bot: bot, chat_id: external_chat_id)
    end

    def leave_chat!
      TelegramChat::LeaveChat.call(bot: bot, chat_id: external_chat_id)
    end

    def current_bot_affected?
      return false unless new_chat_member.dig("user", "is_bot")
      return false if new_chat_member.dig("user", "username") != bot.username

      true
    end

    def current_bot_added?
      new_chat_member["status"] == "member"
    end

    def current_bot_removed?
      new_chat_member["status"] == "left" || new_chat_member["status"] == "kicked"
    end

    def bot_administrator_granted?
      new_chat_member["status"] == "administrator"
    end

    def bot_restricted?
      new_chat_member["status"] == "restricted"
    end

    def external_chat_id
      chat_id.to_i
    end

    def new_chat_member
      payload["new_chat_member"]
    end

    def send_error_to_sentry
      raise NotImplementedError, "do not know how to handle payload #{new_chat_member["status"]}"
    rescue Exception => error
      Sentry.capture_exception(error)
      nil
    end
  end
end
