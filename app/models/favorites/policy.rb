module Favorites
  # Decides whether a user may use the favorites feature. For now it is admin-only; later this is
  # where per-user size limits live and where the feature opens up to everyone.
  class Policy
    def self.can_use?(user)
      new(user).can_use?
    end

    def initialize(user)
      @user = user
    end

    def can_use?
      !!user&.admin?
    end

    private

    attr_reader :user
  end
end
