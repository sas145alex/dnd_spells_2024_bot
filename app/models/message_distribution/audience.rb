class MessageDistribution
  # Builds the recipient scopes (users / chats) for a distribution from its
  # segment snapshot. Used both for the admin preview count and for
  # materializing MessageDelivery rows in Enqueue.
  class Audience < ApplicationOperation
    def initialize(distribution:)
      @distribution = distribution
    end

    def call
      {users: users, chats: chats}
    end

    def users
      return TelegramUser.none unless distribution.send_to_users?

      filter(TelegramUser.all)
    end

    def chats
      return TelegramChat.none unless distribution.send_to_chats?

      filter(TelegramChat.all)
    end

    def total
      users.count + chats.count
    end

    private

    attr_reader :distribution

    def filter(scope)
      scope = scope.active if distribution.only_active?
      scope = scope.where(last_seen_at: distribution.active_since..) if distribution.active_since
      if distribution.min_command_count
        scope = scope.where(command_requested_count: distribution.min_command_count..)
      end
      scope
    end
  end
end
