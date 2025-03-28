module BotCommands
  class GlobalSearch < BaseCommand
    SEARCH_VALUE_MIN_LENGTH = 3
    SEARCH_VALUE_MAX_LENGTH = 30
    DOCUMENTS_PER_PAGE = 10
    PAGE_DELIMETER = "||".freeze
    CALLBACK_PREFIX = "search".freeze
    CALLBACK_PAGE_PREFIX = "#{CALLBACK_PREFIX}_page".freeze

    def self.normalize_input(raw_input)
      raw_input.to_s.strip.gsub(/\s+/, " ").gsub(/^(\/\w+)(@\w+)?(\s+)?/, "").strip
    end

    def self.fetch_text_from(raw_input)
      callback_parts = raw_input.to_s.split("#{CALLBACK_PAGE_PREFIX}:")[1..].join
      parts = callback_parts.split(PAGE_DELIMETER)[..-1]
      return parts.join if parts.size < 2
      parts[0..-2].join
    end

    def self.fetch_page_from(raw_input)
      parts = raw_input.to_s.split(PAGE_DELIMETER)
      return 1 if parts.size < 2
      parts.last.to_i
    end

    def call
      if record_gid.present? && selected_object.present?
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
        empty_dataset = {
          text: "Вариантов не найдено",
          parse_mode: parse_mode
        }
        [{type: :message, answer: empty_dataset}]
      else
        render_type = page_clicked ? :edit : :message
        [{type: render_type, answer: render_search_results}]
      end
    end

    # при смене страницы текст поиска приходит склеинным со страницей в data, а не text
    def initialize(payload: {}, record_gid: nil, page: nil)
      search_input_source = page.blank? ? payload["text"] : self.class.fetch_text_from(payload["data"])
      parsed_page = page.blank? ? 1 : self.class.fetch_page_from(payload["data"])

      @payload = payload
      @input_value = self.class.normalize_input(search_input_source)
      @record_gid = record_gid
      @page = parsed_page
      @page_clicked = !page.nil?
    end

    private

    attr_reader :payload
    attr_reader :input_value
    attr_reader :record_gid
    attr_reader :page
    attr_reader :page_clicked

    def render_record_info
      text = selected_object.description_for_telegram
      mentions = keyboard_mentions_options(selected_object)
      inline_keyboard = mentions.in_groups_of(2, false)
      reply_markup = {inline_keyboard: inline_keyboard}

      {
        text: text,
        reply_markup: reply_markup,
        parse_mode: parse_mode
      }
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
      Multisearchable.search(input_value, scope: scope)
    end

    def links_to_pages
      links = []
      unless first_page?
        previous_page = "#{input_value}#{PAGE_DELIMETER}#{page - 1}"
        links << {
          text: "#{PREVIOUS_PAGE_SYMBOL} Предыдущая страница",
          callback_data: "#{callback_prefix}_page:#{previous_page}"
        }
      end
      unless last_page?
        next_page = "#{input_value}#{PAGE_DELIMETER}#{page + 1}"
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

    def callback_page_prefix
      CALLBACK_PAGE_PREFIX
    end
  end
end
