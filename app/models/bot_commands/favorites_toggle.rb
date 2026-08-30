module BotCommands
  # Handles a tap on the "⭐ В избранное" / "❌ Убрать из избранного" button (callback `fav:<gid>`):
  # adds or removes the record from the user's favorites, then returns the toast to show and the
  # keyboard to edit back in place (the tapped button's label flipped to reflect the new state).
  # Rebuilding from the callback payload's own keyboard keeps every other button on the card intact
  # without the toggle needing to know how that card was originally rendered.
  #
  # A refusal (unavailable / not found / cap reached) returns a toast and no keyboard, which leaves
  # the card exactly as it was — the button label does not flip.
  class FavoritesToggle < BaseCommand
    ADDED_TOAST = "Добавлено в избранное ⭐".freeze
    REMOVED_TOAST = "Убрано из избранного".freeze
    UNAVAILABLE_TOAST = "Избранное пока недоступно".freeze
    NOT_FOUND_TOAST = "Карточка не найдена".freeze
    LIMIT_TOAST = "В избранном максимум #{::Favorites::Policy::FREE_LIMIT} карточек. " \
      "Убери что-нибудь, чтобы добавить новую.".freeze

    def call
      return {toast: UNAVAILABLE_TOAST} unless policy.can_use?
      return {toast: NOT_FOUND_TOAST} unless record.is_a?(::Favoritable)
      return {toast: LIMIT_TOAST} if existing_favorite.nil? && !policy.can_add?

      now_favorited = toggle!
      {
        toast: now_favorited ? ADDED_TOAST : REMOVED_TOAST,
        inline_keyboard: ::Favorites::Button.replace_in(inline_keyboard, gid: gid, favorited: now_favorited)
      }
    end

    def initialize(user:, gid: nil, inline_keyboard: nil)
      @user = user
      @gid = gid
      @inline_keyboard = inline_keyboard
    end

    private

    attr_reader :gid, :inline_keyboard

    def policy
      @policy ||= ::Favorites::Policy.new(user)
    end

    def toggle!
      if existing_favorite
        existing_favorite.destroy!
        false
      else
        user.favorites.create!(favoritable: record)
        true
      end
    end

    def existing_favorite
      return @existing_favorite if defined?(@existing_favorite)

      @existing_favorite = user.favorites.find_by(favoritable: record)
    end

    def record
      return @record if defined?(@record)

      @record = GlobalID::Locator.locate(gid)
    rescue ActiveRecord::RecordNotFound
      @record = nil
    end
  end
end
