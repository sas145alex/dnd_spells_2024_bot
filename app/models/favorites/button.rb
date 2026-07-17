module Favorites
  # Owns the inline "favorite" toggle button: how it is labelled, how it is addressed
  # (`fav:<gid>`), and how it is flipped in an already-rendered keyboard. Built by
  # Presenters::LeafCard when the card is drawn, flipped by BotCommands::FavoritesToggle when it is
  # tapped — keeping both in one place so a label or prefix change cannot drift between them.
  class Button
    ADD_LABEL = "⭐ В избранное".freeze
    REMOVE_LABEL = "❌ Убрать из избранного".freeze
    CALLBACK_PREFIX = "fav".freeze

    def self.for(record, user)
      record = record.object if record.is_a?(Draper::Decorator)
      return nil unless record.is_a?(Favoritable)
      return nil unless Favorites::Policy.can_use?(user)

      {
        text: label(user.favorited?(record)),
        callback_data: callback_data(record.to_global_id)
      }
    end

    # The keyboard comes straight from the Telegram callback payload (JSON), so keys are strings.
    def self.replace_in(inline_keyboard, gid:, favorited:)
      return nil if inline_keyboard.blank?

      inline_keyboard.map do |row|
        row.map do |button|
          button["callback_data"] == callback_data(gid) ? button.merge("text" => label(favorited)) : button
        end
      end
    end

    private_class_method def self.label(favorited)
      favorited ? REMOVE_LABEL : ADD_LABEL
    end

    private_class_method def self.callback_data(gid)
      "#{CALLBACK_PREFIX}:#{gid}"
    end
  end
end
