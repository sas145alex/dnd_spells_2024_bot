module BotCommands
  class Sections < BaseCommand
    AVAILABLE_SECTIONS = {
      "all_spells" => "Заклинания",
      "class" => "Классы",
      "feat" => "Черты",
      "species" => "Виды и расы",
      "origin" => "Происхождения",
      "tool" => "Инструменты",
      "equipment" => "Снаряжение",
      "glossary" => "Глоссарий"
    }.freeze

    def call
      [{type: response_type, answer: all_sections}]
    end

    def initialize(input_value: nil, response_type: :message)
      @input_value = input_value || ""
      @response_type = response_type
    end

    private

    attr_reader :input_value
    attr_reader :response_type

    def all_sections
      text = <<~HTML
        Выбери интересующий раздел
      HTML

      options = keyboard_options
      inline_keyboard = options.in_groups_of(1, false)
      reply_markup = {inline_keyboard: inline_keyboard}

      {
        text: text,
        reply_markup: reply_markup,
        parse_mode: parse_mode
      }
    end

    def keyboard_options
      variants = AVAILABLE_SECTIONS
      variants.map do |section_id, section_title|
        {
          text: section_title,
          callback_data: "#{section_id}:"
        }
      end
    end

    def callback_prefix
      "sections"
    end
  end
end
