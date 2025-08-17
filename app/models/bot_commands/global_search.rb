module BotCommands
  class GlobalSearch < BaseCommand
    SEARCH_VALUE_MIN_LENGTH = 3
    SEARCH_VALUE_MAX_LENGTH = 30
    DOCUMENTS_PER_PAGE = 10
    PAGE_DELIMITER = "||".freeze
    CALLBACK_PREFIX = "search".freeze
    CALLBACK_EN_PREFIX = "search_en".freeze
    CALLBACK_PAGE_PREFIX = "#{CALLBACK_PREFIX}_page".freeze
    RU_SYMBOL = "🇷🇺".freeze
    EN_SYMBOL = "🇺🇸".freeze

    def self.normalize_input(raw_input)
      raw_input.to_s.strip.gsub(/\s+/, " ").gsub(/^(\/\w+)(@\w+)?(\s+)?/, "").strip
    end

    def self.fetch_text_from(raw_input)
      callback_parts = raw_input.to_s.split("#{CALLBACK_PAGE_PREFIX}:")[1..].join
      parts = callback_parts.split(PAGE_DELIMITER)[..-1]
      return parts.join if parts.size < 2
      parts[0..-2].join
    end

    def self.fetch_page_from(raw_input)
      parts = raw_input.to_s.split(PAGE_DELIMITER)
      return 1 if parts.size < 2
      parts.last.to_i
    end

    def call
      if record_gid.present? && selected_object.present?
        gather_metrics_for_selected_object
        [{type: :message, answer: render_record_info}]
      elsif record_gid.present?
        record_not_found = {
          text: "Указанный объект не найден",
          parse_mode: parse_mode
        }
        [{type: :message, answer: record_not_found}]
      elsif input_value.size < SEARCH_VALUE_MIN_LENGTH || input_value.size > SEARCH_VALUE_MAX_LENGTH
        text = <<~HTML
          Неверное количество символов. Минимум - #{SEARCH_VALUE_MIN_LENGTH}, максимум - #{SEARCH_VALUE_MAX_LENGTH}

          При необходимости можешь поставить фильтр на секции поиска.
          
          Если ты используешь бота в чатах, то можешь вызывать команду так: 
          <blockquote>/search@sneaky_library_bot огненный шар</blockquote>
          
          Если ты общаешься с ботом лично, то эту команду можно вызывать так:
          <blockquote>
            /search огненный шар
            /s огненный шар
            огненный шар # (да, без указания команды!)
          </blockquote>
        HTML
        invalid_input = {
          text: text,
          parse_mode: parse_mode
        }
        [{type: :message, answer: invalid_input}]
      elsif found_records.blank?
        options = []
        inline_keyboard = options.in_groups_of(1, false)
        inline_keyboard.prepend(links_to_filters)
        reply_markup = {inline_keyboard: inline_keyboard}
        empty_dataset = {
          text: "Вариантов не найдено",
          reply_markup: reply_markup,
          parse_mode: parse_mode
        }

        [{type: :message, answer: empty_dataset}]
      else
        render_type = page_clicked ? :edit : :message
        [{type: render_type, answer: render_search_results}]
      end
    end

    # при смене страницы текст поиска приходит склеинным со страницей в data, а не text
    def initialize(user:, payload: {}, locale: :ru, record_gid: nil, page: nil)
      search_input_source = page.blank? ? payload["text"] : self.class.fetch_text_from(payload["data"])
      parsed_page = page.blank? ? 1 : self.class.fetch_page_from(payload["data"])

      @payload = payload
      @input_value = self.class.normalize_input(search_input_source)
      @locale = locale
      @record_gid = record_gid
      @page = parsed_page
      @page_clicked = !page.nil?
      @user = user
    end

    private

    attr_reader :payload
    attr_reader :input_value
    attr_reader :locale
    attr_reader :record_gid
    attr_reader :page
    attr_reader :page_clicked
    attr_reader :user

    def render_record_info
      text = if locale == :ru
        selected_object.description_for_telegram
      else
        selected_object.original_description_for_telegram
      end
      mentions = keyboard_mentions_options(selected_object)
      inline_keyboard = mentions.in_groups_of(2, false)
      inline_keyboard.prepend([link_to_change_locale]) if selected_object.support_other_languages?
      reply_markup = {inline_keyboard: inline_keyboard}

      {
        text: text,
        reply_markup: reply_markup,
        parse_mode: parse_mode
      }
    end

    def link_to_change_locale
      change_locale_text = (locale == :ru) ? "EN #{EN_SYMBOL}" : "RU #{RU_SYMBOL}"
      change_locale_prefix = (locale == :ru) ? callback_en_prefix : callback_prefix
      {
        text: change_locale_text,
        callback_data: "#{change_locale_prefix}:#{selected_object.to_global_id}"
      }
    end

    def gather_metrics_for_selected_object
      case selected_object
      when Spell
        Telegram::SpellMetricsJob.perform_later(spell_gid: record_gid)
      else
        # do nothing
        nil
      end
    end

    def render_search_results
      text = <<~HTML.chomp
        <b>Поиск</b> - #{input_value}
        <b>Страница:</b> #{paged_documents.current_page} / #{paged_documents.total_pages}
        Выбери:
      HTML
      variants = found_records
      options = keyboard_options(variants, title_method: :global_search_title)
      inline_keyboard = options.in_groups_of(1, false)
      inline_keyboard.prepend(links_to_filters)
      inline_keyboard.append(links_to_pages)
      reply_markup = {inline_keyboard: inline_keyboard}

      {
        text: text,
        reply_markup: reply_markup,
        parse_mode: parse_mode
      }
    end

    def found_records
      @found_records ||= paged_documents.map(&:searchable).map(&:decorate)
    end

    def paged_documents
      documents_scope.page(page).per(DOCUMENTS_PER_PAGE)
    end

    def documents_scope
      scope = PgSearch::Document.where(published: true)
      scope = scope.where.not(searchable_type: user.unselected_search_categories)
      Multisearchable.search(input_value, scope: scope)
    end

    def links_to_filters
      links = []
      links << {
        text: "Фильтры #{FILTERS_PAGE_SYMBOL}",
        callback_data: "search_filters:"
      }
      links
    end

    def links_to_pages
      links = []
      unless first_page?
        previous_page = "#{input_value}#{PAGE_DELIMITER}#{page - 1}"
        links << {
          text: "#{PREVIOUS_PAGE_SYMBOL} Предыдущая страница",
          callback_data: "#{callback_prefix}_page:#{previous_page}"
        }
      end
      unless last_page?
        next_page = "#{input_value}#{PAGE_DELIMITER}#{page + 1}"
        links << {
          text: "Следующая страница #{NEXT_PAGE_SYMBOL}",
          callback_data: "#{callback_page_prefix}:#{next_page}"
        }
      end
      links
    end

    def first_page?
      paged_documents.first_page?
    end

    def last_page?
      paged_documents.last_page?
    end

    def gid_value
      record_gid
    end

    def callback_prefix
      CALLBACK_PREFIX
    end

    def callback_en_prefix
      CALLBACK_EN_PREFIX
    end

    def callback_page_prefix
      CALLBACK_PAGE_PREFIX
    end
  end
end
