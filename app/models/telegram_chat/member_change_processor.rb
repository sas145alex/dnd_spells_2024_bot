class TelegramChat
  class MemberChangeProcessor < ApplicationOperation
    def initialize(bot:, payload:)
      @bot = bot
      @payload = payload
    end

    # bot added to a chat
    # {"chat"=>{"id"=>-4772963005, "title"=>"chat with test bot", "type"=>"group", "all_members_are_administrators"=>true},
    #  "from"=>{"id"=>350564680, "is_bot"=>false, "first_name"=>"some_first_name", "last_name"=>"some_last_name", "username"=>"some_username", "language_code"=>"en"},
    #  "date"=>1734539200,
    #  "old_chat_member"=>{"user"=>{"id"=>7412437273, "is_bot"=>true, "first_name"=>"dnd_spells_2024_dev", "username"=>"dnd_spells_2024_dev_bot"}, "status"=>"member"},
    #  "new_chat_member"=>{"user"=>{"id"=>7412437273, "is_bot"=>true, "first_name"=>"dnd_spells_2024_dev", "username"=>"dnd_spells_2024_dev_bot"}, "status"=>"left"}}

    # bot removed from a chat
    # {"chat"=>{"id"=>-4772963005, "title"=>"chat with test bot", "type"=>"group", "all_members_are_administrators"=>true},
    #  "from"=>{"id"=>350564680, "is_bot"=>false, "first_name"=>"some_first_name", "last_name"=>"some_last_name", "username"=>"some_username", "language_code"=>"en"},
    #  "date"=>1734539224,
    #  "old_chat_member"=>{"user"=>{"id"=>7412437273, "is_bot"=>true, "first_name"=>"dnd_spells_2024_dev", "username"=>"dnd_spells_2024_dev_bot"}, "status"=>"left"},
    #  "new_chat_member"=>{"user"=>{"id"=>7412437273, "is_bot"=>true, "first_name"=>"dnd_spells_2024_dev", "username"=>"dnd_spells_2024_dev_bot"}, "status"=>"member"}}
    def call
      return unless current_bot_affected?

      if current_bot_added?
        add_bot_to_chat
      elsif current_bot_removed?
        remove_bot_from_chat
      else
        raise NotImplementedError, "do not know how to handle payload #{payload}"
      end
    end

    private

    attr_reader :bot
    attr_reader :payload

    def add_bot_to_chat
      chat = TelegramChat.find_or_create_by!(external_id: external_chat_id.to_i) do |new_chat|
        new_chat.last_seen_at = Time.current
      end
      chat.update!(bot_added_at: Time.current, bot_removed_at: nil)
    end

    def remove_bot_from_chat
      chat = TelegramChat.find_or_create_by!(external_id: external_chat_id.to_i) do |new_chat|
        new_chat.last_seen_at = Time.current
        new_chat.bot_added_at = Time.current
      end
      chat.update!(bot_removed_at: Time.current)
    end

    def current_bot_affected?
      return false if new_chat_member["user"]["is_bot"] == false
      return false if new_chat_member["user"]["username"] != "#{bot.username}_bot"

      true
    end

    def current_bot_added?
      new_chat_member["status"] == "member"
    end

    def current_bot_removed?
      new_chat_member["status"] == "left"
    end

    def external_chat_id
      payload["chat"]["id"]
    end

    def new_chat_member
      payload["new_chat_member"]
    end
  end
end
