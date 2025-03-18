module BotCommands
  class GlobalSearch < BaseCommand
    SEARCH_VALUE_MIN_LENGTH = 3
    SEARCH_VALUE_MAX_LENGTH = 50
    MAX_SEARCH_RESULT_COUNT = 10

    def self.normalize_input(raw_input)
      raw_input.to_s.strip.gsub(/\s+/, " ").gsub(/^(\/\w+)(@\w+)?(\s+)?/, "").strip
    end

    def call
      if record_gid.present? && selected_object.present?
        render_record_info
      elsif record_gid.present?
        {
          text: "Указанный объект не найден",
          parse_mode: parse_mode
        }
      elsif input_value.size < SEARCH_VALUE_MIN_LENGTH || input_value.size > SEARCH_VALUE_MAX_LENGTH
        text = <<~HTML
          Неверное количество символов. Минимум - #{SEARCH_VALUE_MIN_LENGTH}, максимум - #{SEARCH_VALUE_MAX_LENGTH}
          
          Если ты используешь бота в чатах, то можешь вызывать команду так: 
          <blockquote>/search огненный шар</blockquote>
          
          Если ты общаешься с ботом лично, то не обязательно даже указывать эту команду:
          <blockquote>огненный шар</blockquote>
        HTML
        {
          text: text,
          parse_mode: parse_mode
        }
      elsif found_records.blank?
        {
          text: "Вариантов не найдено",
          parse_mode: parse_mode
        }
      else
        render_search_results
      end
    end

    def initialize(payload: {}, record_gid: nil)
      @payload = payload
      @input_value = self.class.normalize_input(payload["text"])
      @record_gid = record_gid
    end

    private

    attr_reader :payload
    attr_reader :input_value
    attr_reader :record_gid

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
      text = "Найдено несколько вариантов. Выбери:\n\n"
      variants = found_records
      options = keyboard_options(variants, title_method: :global_search_title)
      inline_keyboard = options.in_groups_of(1, false)
      reply_markup = {inline_keyboard: inline_keyboard}

      {
        text: text,
        reply_markup: reply_markup,
        parse_mode: parse_mode
      }
    end

    def found_records
      @found_records ||= begin
        scope = PgSearch::Document.where(published: true)
        documents = Multisearchable.search(input_value, scope: scope, limit: MAX_SEARCH_RESULT_COUNT)
        documents.map(&:searchable).map(&:decorate)
      end
    end

    def gid_value
      record_gid
    end

    def callback_prefix
      "search"
    end
  end
end
