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
      "bastion" => "Бастионы",
      "glossary" => "Глоссарий"
    }.freeze

    def call
      [{type: response_type, answer: all_sections}]
    end

    def initialize(input_value: nil, response_type: :message, user: nil)
      @input_value = input_value || ""
      @response_type = response_type
      @user = user
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
      options = AVAILABLE_SECTIONS.map do |section_id, section_title|
        {
          text: section_title,
          callback_data: "#{section_id}:"
        }
      end
      options << favorites_option if ::Favorites::Policy.can_use?(user)
      options
    end

    def favorites_option
      {text: FavoritesList::HEADER, callback_data: "#{FavoritesList::CALLBACK_PREFIX}:"}
    end

    def callback_prefix
      "sections"
    end
  end
end
