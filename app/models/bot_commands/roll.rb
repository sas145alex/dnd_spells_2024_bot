module BotCommands
  class Roll < BaseCommand
    PAGES = (1..10).to_a.freeze
    DICE_PER_PAGE = 5
    MAX_ROLL_FORMULAS = 5

    def call
      if invalid_input?
        [{type: :message, answer: invalid_input}]
      elsif can_roll_the_dices? && manual_input
        [{type: :reply, answer: calculate_roll}]
      elsif can_roll_the_dices?
        [{type: :edit, answer: calculate_roll}]
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
      roll_texts = roll_formulas.map(&:to_s)
      if roll_formulas.size > 1
        sum_of_all_rolls = "<b>Итог:</b> #{roll_formulas.map(&:rolls_sum_total).sum}"
        roll_texts << sum_of_all_rolls
      end
      text = roll_texts.join("\n\n")

      buttons = [{text: "Другой бросок", callback_data: "#{callback_prefix}:"}]
      inline_keyboard = buttons.in_groups_of(2, false)
      reply_markup = {inline_keyboard: inline_keyboard}

      {
        text: text,
        reply_markup: reply_markup,
        parse_mode: parse_mode
      }
    end

    def provide_dices
      text = <<~HTML.chomp
        Для мгновенного броска ты можешь вызвать команду с нужными значениями в формате: <blockquote>/roll ХdY+Z</blockquote>
        
        Примеры вызова команды:
        <blockquote>
        /roll 2d20
        /r 2d20
        /roll 3d4+3
        /r 1d10-1 4d4+2 5d5
        </blockquote>
        
        Для броска выбери кость из таблицы:
      HTML
      reply_markup = {inline_keyboard: keyboard_dices_options}

      {
        text: text,
        reply_markup: reply_markup,
        parse_mode: parse_mode
      }
    end

    def keyboard_dices_options
      keyboard = []
      keyboard << [build_variant_for(1, 20, label: "🎲 1d20")]
      keyboard << [build_variant_for(2, 20, label: "Помеха / Преимущество")]

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

    def build_variant_for(nominal, value, label: nil)
      text = label.presence || "#{nominal}d#{value}"
      {text: text, callback_data: "roll:#{nominal}d#{value}"}
    end

    def dice_counts
      options = (1..DICE_PER_PAGE).to_a
      options.map! { it + DICE_PER_PAGE * (page - 1) }
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
      input_value.present? && !can_roll_the_dices?
    end

    def first_page?
      page == PAGES.first
    end

    def last_page?
      page == PAGES.last
    end

    def can_roll_the_dices?
      roll_formulas.size <= MAX_ROLL_FORMULAS && roll_formulas.all?(&:valid?)
    end

    def roll_formulas
      @roll_formulas ||= begin
        formulas = input_value.include?(" ") ? input_value.split(" ") : [input_value]
        formulas.map { RollFormula.new(it) }
      end
    end

    def callback_prefix
      "roll"
    end
  end
end
