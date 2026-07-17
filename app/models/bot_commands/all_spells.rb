module BotCommands
  class AllSpells < BaseCommand
    SPELLS_PER_PAGE = 10

    def call
      if invalid_input?
        [{type: :message, answer: invalid_input}]
      elsif selected_object.is_a?(Spell)
        [{type: :edit, answer: render_spell_info}]
      else
        [{type: :edit, answer: provide_spells}]
      end
    end

    def initialize(session:, input_value: nil, page: nil, user: nil)
      @input_value = input_value || ""
      @is_page_scrolled = !page.nil?
      @page = page.blank? ? 1 : page.to_i
      @session = session
      @user = user
    end

    private

    attr_reader :input_value
    attr_reader :is_page_scrolled
    attr_reader :page
    attr_reader :session

    def render_spell_info
      Presenters::LeafCard.call(object: selected_object, user: user, mention_columns: 4)
    end

    def provide_spells
      options = keyboard_options(paged_spells.map(&:decorate))

      text = <<~HTML.chomp
        <b>Подходящих заклинаний:</b> #{spells_scope.count}
        <b>Страница:</b> #{paged_spells.current_page} / #{paged_spells.total_pages}
        #{display_current_filters}

        Выбери заклинание:
      HTML

      inline_keyboard = options.in_groups_of(1, false)
      inline_keyboard.append(links_to_pages(paged_spells))
      inline_keyboard.append([link_to_filters])
      inline_keyboard.append([link_to_sections])
      reply_markup = {inline_keyboard: inline_keyboard}

      {
        text: text,
        reply_markup: reply_markup,
        parse_mode: parse_mode
      }
    end

    def display_current_filters
      BotCommands::AllSpellsFilters::DisplayFilters.call(current_filters)
    end

    def link_to_filters
      {
        text: "Фильтры #{FILTERS_PAGE_SYMBOL}",
        callback_data: "all_spells_filters:"
      }
    end

    def link_to_sections
      {text: "Ко всем разделам", callback_data: "sections:"}
    end

    def invalid_input?
      false
    end

    def paged_spells
      @paged_spells ||= spells_scope.page(page).per(SPELLS_PER_PAGE)
    end

    def spells_scope
      @spells_scope ||= begin
        scope = Spell.published.order(:level, :title)
        scope = BotCommands::AllSpellsFilters::ApplyFilters.call(scope: scope, filters: current_filters)
        scope
      end
    end

    def callback_prefix
      "all_spells"
    end

    def current_filters
      session[BotCommands::AllSpellsFilters::SESSION_KEY] || {}
    end
  end
end
