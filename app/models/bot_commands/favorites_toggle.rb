module BotCommands
  # Handles a tap on the "⭐ В избранное" / "❌ Убрать из избранного" button (callback `fav:<gid>`):
  # adds or removes the record from the user's favorites, then returns the toast to show and the
  # keyboard to edit back in place (the tapped button's label flipped to reflect the new state).
  # Rebuilding from the callback payload's own keyboard keeps every other button on the card intact
  # without the toggle needing to know how that card was originally rendered.
  class FavoritesToggle < BaseCommand
    ADDED_TOAST = "Добавлено в избранное ⭐".freeze
    REMOVED_TOAST = "Убрано из избранного".freeze
    UNAVAILABLE_TOAST = "Избранное пока недоступно".freeze
    NOT_FOUND_TOAST = "Карточка не найдена".freeze

    def call
      return {toast: UNAVAILABLE_TOAST} unless ::Favorites::Policy.can_use?(user)
      return {toast: NOT_FOUND_TOAST} if record.nil?

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

    def toggle!
      existing = user.favorites.find_by(favoritable: record)
      if existing
        existing.destroy!
        false
      else
        user.favorites.create!(favoritable: record)
        true
      end
    end

    def record
      return @record if defined?(@record)

      @record = GlobalID::Locator.locate(gid)
    rescue ActiveRecord::RecordNotFound
      @record = nil
    end
  end
end
