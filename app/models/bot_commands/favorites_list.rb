module BotCommands
  # The "⭐ Избранное" section: a paginated list of every card the user has favorited (any content
  # type), each opening the record's card with a "Назад" that returns to the list via the history
  # stack. Dispatched on input_value like the other section commands: blank → the list, a GlobalID
  # → the card. Open to every user; non-admins are capped at Favorites::Policy::FREE_LIMIT cards.
  class FavoritesList < BaseCommand
    # Currently equal to Favorites::Policy::FREE_LIMIT, so the pager only engages for uncapped users.
    FAVORITES_PER_PAGE = 10
    CALLBACK_PREFIX = "favorites".freeze
    HEADER = "⭐ Избранное".freeze

    def call
      [{type: response_type, answer: answer}]
    end

    def initialize(user:, input_value: nil, page: nil, response_type: :edit)
      @user = user
      @input_value = input_value.to_s
      @page = page.blank? ? 1 : page.to_i
      @response_type = response_type
    end

    private

    attr_reader :input_value, :page, :response_type

    def answer
      return notice("Избранное пока недоступно.") unless favorites_policy.can_use?
      return render_list if input_value.blank?
      return notice("Карточка не найдена. Возможно, она была удалена.") if selected_object.blank?

      render_card
    end

    def render_list
      return empty_list if paged_favorites.total_count.zero?

      options = keyboard_options(favorited_records, title_method: :global_search_title, mark_favorites: false)
      inline_keyboard = options.in_groups_of(1, false)
      page_links = links_to_pages(paged_favorites)
      inline_keyboard.append(page_links) if page_links.any?
      inline_keyboard.append([go_back_button])

      {
        text: list_text,
        reply_markup: {inline_keyboard: inline_keyboard},
        parse_mode: parse_mode
      }
    end

    def render_card
      Presenters::LeafCard.call(object: selected_object, user: user)
    end

    def list_text
      <<~HTML.chomp
        <b>#{HEADER}</b>
        #{counter_line}
        <b>Страница:</b> #{paged_favorites.current_page} / #{paged_favorites.total_pages}
        Выбери карточку:
      HTML
    end

    # total_count is already loaded for the pager, so the counter costs no extra query.
    def counter_line
      "<b>Карточек:</b> #{[paged_favorites.total_count, favorites_policy.limit].compact.join(" / ")}"
    end

    def empty_list
      notice("У тебя пока нет избранного.\nДобавляй карточки кнопкой «#{::Favorites::Button::ADD_LABEL}» под их описанием.")
    end

    def notice(text)
      {
        text: text,
        reply_markup: {inline_keyboard: [[go_back_button]]},
        parse_mode: parse_mode
      }
    end

    def favorited_records
      paged_favorites.map(&:favoritable).compact.map(&:decorate)
    end

    def paged_favorites
      @paged_favorites ||= favorites_scope.includes(:favoritable).page(page).per(FAVORITES_PER_PAGE)
    end

    # Deliberately not scoped to `.published`: once a card is favorited it stays reachable here even
    # if it is later unpublished, so a user's list never silently loses entries.
    def favorites_scope
      user.favorites.order(created_at: :desc)
    end

    def callback_prefix
      CALLBACK_PREFIX
    end
  end
end
