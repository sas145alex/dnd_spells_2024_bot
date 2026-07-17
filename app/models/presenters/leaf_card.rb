module Presenters
  # Builds the answer hash for a single content "card" (the leaf screen showing a record's
  # description). Centralizes the keyboard every card shares — favorite toggle, RU/EN locale
  # toggle, mention buttons and the "Назад" button — so the favorite button appears uniformly on
  # every card. Callers pass their own `text` (default: the record's description).
  class LeafCard < ApplicationOperation
    RU_SYMBOL = "🇷🇺".freeze
    EN_SYMBOL = "🇺🇸".freeze
    MENTION_COLUMNS = 2
    GO_BACK_BUTTON = {text: "Назад", callback_data: "go_back:go_back"}.freeze

    def initialize(object:, user:, text: nil, locale: :ru, back_button: true, locale_toggle: false, mention_columns: MENTION_COLUMNS, extra_rows: [])
      @decorated = object.is_a?(Draper::Decorator) ? object : object.decorate
      @user = user
      @text = text
      @locale = locale.to_sym
      @back_button = back_button
      @locale_toggle = locale_toggle
      @mention_columns = mention_columns
      @extra_rows = extra_rows
    end

    def call
      {
        text: body_text,
        reply_markup: {inline_keyboard: inline_keyboard},
        parse_mode: decorated.parse_mode_for_telegram
      }
    end

    private

    attr_reader :decorated, :user, :locale, :back_button, :locale_toggle, :mention_columns, :extra_rows

    def record
      decorated.object
    end

    def body_text
      return @text if @text.present?

      description, header, missing_text = if locale == :en
        [decorated.original_description_for_telegram, decorated.original_title, "No description available."]
      else
        [decorated.description_for_telegram, decorated.title, "Описание отсутствует."]
      end
      description.presence || "<b>#{header}</b>\n\n#{missing_text}"
    end

    def inline_keyboard
      rows = []
      favorite = Favorites::Button.for(record, user)
      rows << [favorite] if favorite
      rows << [locale_toggle_button] if locale_toggle && decorated.support_other_languages?
      rows.concat(mention_rows)
      rows.concat(extra_rows)
      rows << [GO_BACK_BUTTON] if back_button
      rows
    end

    # Both halves of the toggle route back into global search, which owns those callback prefixes.
    def locale_toggle_button
      if locale == :en
        {text: "RU #{RU_SYMBOL}", callback_data: "#{BotCommands::GlobalSearch::CALLBACK_PREFIX}:#{record.to_global_id}"}
      else
        {text: "EN #{EN_SYMBOL}", callback_data: "#{BotCommands::GlobalSearch::CALLBACK_EN_PREFIX}:#{record.to_global_id}"}
      end
    end

    def mention_rows
      MentionButtons.for(decorated).in_groups_of(mention_columns, false)
    end
  end
end
