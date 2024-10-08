module BotCommands
  class Roll < BaseCommand
    PAGES = (1..10).to_a.freeze
    DICE_PER_PAGE = 5
    BASE_ROLL_REGEXP = /^(?<dice_count>\d+)(?<second_part>\w(?<dice_value>\d+))/
    MOD_ROLL_REGEXP = /(?<mod_sign>[\+\-])?(?<mod_value>\d+)?/
    ROLL_FORMULA_REGEXP = Regexp.new(BASE_ROLL_REGEXP.source + MOD_ROLL_REGEXP.source)

    def call
      if invalid_input?
        [{type: :message, answer: invalid_input}]
      elsif full_roll_formula?
        [{type: :message, answer: calculate_roll}, {type: :message, answer: provide_dices}]
      elsif is_page_scrolled
        [{type: :edit, answer: provide_dices}]
      else
        [{type: :message, answer: provide_dices}]
      end
    end

    def initialize(input_value: nil, page: nil)
      @input_value = input_value || ""
      @is_page_scrolled = !page.nil?
      @page = page || 1
    end

    private

    attr_reader :input_value
    attr_reader :page
    attr_reader :is_page_scrolled

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
      text = <<~HTML
        <b>Бросок:</b> #{input_value}
        <b>Все результаты:</b> #{rolls.sort.join(", ")}
        <b>Модификатор:</b> #{mod_sign}#{mod_value}
        <b>Сумма:</b> #{sum}
        <b>Сумма с модификатором:</b> #{mod_sum}
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
      is_invalid_formula = input_value.present? && roll_formula.nil?
      return true if is_invalid_formula
      roll_formula.present? && (dice_count.to_i > 100 || dice_value.to_i > 100)
    end

    def first_page?
      page == PAGES.first
    end

    def last_page?
      page == PAGES.last
    end

    def full_roll_formula?
      dice_value && dice_count
    end

    def dice_count
      roll_formula.try(:[], :dice_count).nil? ? nil : roll_formula[:dice_count].to_i
    end

    def dice_value
      roll_formula.try(:[], :dice_value).nil? ? nil : roll_formula[:dice_value].to_i
    end

    def mod_value
      roll_formula[:mod_value].to_i
    end

    def mod_sign
      (roll_formula[:mod_sign] || "+").to_s.to_sym
    end

    def roll_formula
      @roll_formula ||= input_value.match(ROLL_FORMULA_REGEXP)
    end
  end
end
