module Favorites
  # Decides whether a user may use the favorites feature, and how many cards they may keep. Open to
  # every Telegram user: admins keep an unlimited list, everyone else is capped at FREE_LIMIT.
  class Policy
    FREE_LIMIT = 10

    def self.can_use?(user)
      new(user).can_use?
    end

    def initialize(user)
      @user = user
    end

    def can_use?
      user.present?
    end

    # nil means uncapped — admins are not limited.
    def limit
      return nil if user&.admin?

      FREE_LIMIT
    end

    # Two taps arriving at once can both pass this and put a user one card over the cap. Not worth
    # locking for a 10-card limit: the unique index still rules out duplicates, and the worst
    # outcome is a single bonus card.
    def can_add?
      can_use? && (limit.nil? || used < limit)
    end

    private

    attr_reader :user

    def used
      @used ||= user.favorites.count
    end
  end
end
