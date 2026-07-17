module BotCommands
  class BaseCommand < ApplicationOperation
    PREVIOUS_PAGE_SYMBOL = "⬅️".freeze
    NEXT_PAGE_SYMBOL = "➡️".freeze
    FILTERS_PAGE_SYMBOL = "📃".freeze
    SEARCH_BY_CHARACTERISTIC_SUBCOMMAND = {text: "Поиск по хар-ке", value: "search_by_characteristic"}.freeze

    private

    # Every command that renders a card is handed the current user (Presenters::LeafCard needs it
    # for the favorite button), so the reader belongs to the shared contract.
    attr_reader :user

    def invalid_input
      {
        text: "Невалидный ввод",
        reply_markup: {},
        parse_mode: parse_mode
      }
    end

    def go_back_button
      Presenters::LeafCard::GO_BACK_BUTTON
    end

    def links_to_pages(paged_scope, page_prefix = "#{callback_prefix}_page")
      links = []
      unless paged_scope.first_page?
        links << {text: "#{PREVIOUS_PAGE_SYMBOL} Предыдущая страница", callback_data: "#{page_prefix}:#{paged_scope.current_page - 1}"}
      end
      unless paged_scope.last_page?
        links << {text: "Следующая страница #{NEXT_PAGE_SYMBOL}", callback_data: "#{page_prefix}:#{paged_scope.current_page + 1}"}
      end
      links
    end

    # `mark_favorites: false` is for screens where every row is a favorite anyway (the favorites
    # list itself) — Favorites::Marks is lazy, so it costs no query there.
    def keyboard_options(variants, forced_callback_prefix: nil, title_method: :title, mark_favorites: true)
      prefix = forced_callback_prefix || callback_prefix
      marks = ::Favorites::Marks.for(variants, user)
      variants.map do |variant|
        title = variant.public_send(title_method)
        {
          text: mark_favorites ? marks.label(variant, title) : title,
          callback_data: "#{prefix}:#{variant.to_global_id}"
        }
      end
    end

    def callback_prefix
      raise NotImplementedError
    end

    def search_by_characteristic_subcommand
      {
        text: SEARCH_BY_CHARACTERISTIC_SUBCOMMAND[:text],
        callback_data: "#{callback_prefix}:#{SEARCH_BY_CHARACTERISTIC_SUBCOMMAND[:value]}"
      }
    end

    def characteristic_search_selected?
      input_value == SEARCH_BY_CHARACTERISTIC_SUBCOMMAND[:value]
    end

    def selected_object
      @selected_object ||= GlobalID::Locator.locate(gid_value)&.decorate
    rescue ActiveRecord::RecordNotFound
      nil
    end

    def gid_value
      input_value
    end

    def parse_mode
      "HTML"
    end

    def locale
      "ru"
    end
  end
end
