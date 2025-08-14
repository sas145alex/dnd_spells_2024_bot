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

    def initialize(session:, input_value: nil, page: nil)
      @input_value = input_value || ""
      @is_page_scrolled = !page.nil?
      @page = page.blank? ? 1 : page.to_i
      @session = session
    end

    private

    attr_reader :input_value
    attr_reader :is_page_scrolled
    attr_reader :page
    attr_reader :session

    def render_spell_info
      text = selected_object.description_for_telegram
      mentions = selected_object.mentions.map do |mention|
        {
          text: mention.another_mentionable.decorate.title,
          callback_data: "pick_mention:#{mention.id}"
        }
      end

      inline_keyboard = mentions.in_groups_of(4, false)
      inline_keyboard.append([go_back_button])
      reply_markup = {inline_keyboard: inline_keyboard}

      {
        text: text,
        reply_markup: reply_markup,
        parse_mode: parse_mode
      }
    end

    def provide_spells
      options = paged_spells.map do |spell|
        item = spell.decorate
        {
          text: item.title,
          callback_data: "#{callback_prefix}:#{item.to_global_id}"
        }
      end

      text = <<~HTML.chomp
        <b>Подходящих заклинаний:</b> #{spells_scope.count}
        <b>Страница:</b> #{paged_spells.current_page} / #{paged_spells.total_pages}
        #{display_current_filters}

        Выбери заклинание:
      HTML

      inline_keyboard = options.in_groups_of(1, false)
      inline_keyboard.append(links_to_pages)
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

    def links_to_pages
      links = []
      unless first_page?
        links << {text: "#{PREVIOUS_PAGE_SYMBOL} Предыдущая страница", callback_data: "#{callback_prefix}_page:#{page - 1}"}
      end
      unless last_page?
        links << {text: "Следующая страница #{NEXT_PAGE_SYMBOL}", callback_data: "#{callback_prefix}_page:#{page + 1}"}
      end
      links
    end

    def link_to_sections
      {text: "Ко всем разделам", callback_data: "sections:"}
    end

    def invalid_input?
      false
    end

    def first_page?
      paged_spells.first_page?
    end

    def last_page?
      paged_spells.last_page?
    end

    def paged_spells
      spells_scope.page(page).per(SPELLS_PER_PAGE)
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
