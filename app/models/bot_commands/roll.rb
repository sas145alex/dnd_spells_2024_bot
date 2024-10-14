module BotCommands
  class Roll < BaseCommand
    PAGES = (1..10).to_a.freeze
    DICE_PER_PAGE = 5

    def call
      if invalid_input?
        [{type: :message, answer: invalid_input}]
      elsif can_roll_the_dice? && manual_input
        [{type: :reply, answer: calculate_roll}, {type: :message, answer: provide_dices}]
      elsif can_roll_the_dice?
        [{type: :edit, answer: calculate_roll}, {type: :message, answer: provide_dices}]
      elsif is_page_scrolled
        [{type: :edit, answer: provide_dices}]
      else
        [{type: :message, answer: provide_dices}]
      end
    end

    def initialize(input_value: nil, page: nil, manual_input: false)
      @input_value = input_value || ""
      @is_page_scrolled = !page.nil?
      @page = page || 1
      @manual_input = manual_input
    end

    private

    attr_reader :input_value
    attr_reader :is_page_scrolled
    attr_reader :page
    attr_reader :manual_input

    delegate :dice_count,
      :dice_value,
      :mod_value,
      :mod_sign,
      to: :roll_formula

    def invalid_input
      text = "Неправильный формат формулы для броска"
      reply_markup = {}

      {
        text: text,
        reply_markup: reply_markup,
        parse_mode: parse_mode
      }
    end

    def calculate_roll
      rolls = (1..dice_count).to_a.map { rand(1..dice_value) }
      sum = rolls.sum
      mod_sum = (mod_sign == :+) ? sum + mod_value : sum - mod_value
      mod_text = if mod_value.zero?
        ""
      else
        <<~HTML
          <b>Сумма без модификатора:</b> #{sum}
          <b>Модификатор:</b> #{mod_sign}#{mod_value}
        HTML
      end
      text = <<~HTML.chomp
        <b>Бросок:</b> 🎲 #{input_value}
        <b>Все результаты:</b> #{rolls.sort.join(", ")}
        #{mod_text}

        <b>Итог:</b> #{mod_sum}
      HTML
      reply_markup = {}

      {
        text: text,
        reply_markup: reply_markup,
        parse_mode: parse_mode
      }
    end

    def provide_dices
      text = "Выберете кость для броска:"
      reply_markup = {inline_keyboard: keyboard_dices_options}

      {
        text: text,
        reply_markup: reply_markup,
        parse_mode: parse_mode
      }
    end

    def keyboard_dices_options
      keyboard = []
      keyboard << [build_variant_for(1, 20)]

      dice_nominals.each do |nominal|
        row = dice_counts.map do |dice_count|
          build_variant_for(dice_count, nominal)
        end
        keyboard << row
      end
      keyboard << [build_variant_for(1, 100)]
      keyboard << links_to_pages
      keyboard
    end

    def build_variant_for(nominal, value)
      {text: "#{nominal}d#{value}", callback_data: "roll:#{nominal}d#{value}"}
    end

    def dice_counts
      options = (1..DICE_PER_PAGE).to_a
      options.map! { _1 + DICE_PER_PAGE * (page - 1) }
    end

    def dice_nominals
      [20, 12, 10, 8, 6, 4]
    end

    def links_to_pages
      links = []
      links << {text: "Предыдущая страница", callback_data: "roll_page:#{page - 1}"} unless first_page?
      links << {text: "Следующая страница", callback_data: "roll_page:#{page + 1}"} unless last_page?
      links
    end

    def invalid_input?
      input_value.present? && roll_formula.invalid?
    end

    def first_page?
      page == PAGES.first
    end

    def last_page?
      page == PAGES.last
    end

    def can_roll_the_dice?
      input_value.present? && roll_formula.valid?
    end

    def roll_formula
      @roll_formula ||= RollFormula.new(input_value)
    end
  end
end
