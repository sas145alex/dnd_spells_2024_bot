class BotCommand::Roll < ApplicationOperation
  ROLL_FORMULA_REGEXP = /^(?<dice_count>\d+)(?<second_part>\w(?<dice_value>\d+))?$/

  def call
    {
      text: text,
      reply_markup: reply_markup,
      parse_mode: parse_mode
    }
  end

  def initialize(roll_formula: nil)
    @roll_formula = roll_formula
  end

  private

  attr_reader :roll_formula

  def text
    if invalid_input?
      "Неправильный формат формулы для броска"
    elsif full_roll_formula?
      rolls = (1..dice_count).to_a.map { rand(1..dice_value) }
      <<~HTML
        <b>Бросок:</b> #{dice_count}d#{dice_value}
        <b>Все результаты:</b> #{rolls.sort.join(", ")}
        <b>Сумма:</b> #{rolls.sum}
      HTML
    elsif partial_roll_formula?
      "<b>Количество костей: #{dice_count}</b>\n\nВыбери номинал костей:"
    else
      "Выберете количество костей:"
    end
  end

  def reply_markup
    if invalid_input?
      {}
    elsif full_roll_formula?
      {}
    elsif partial_roll_formula?
      inline_keyboard = keyboard_options(callback_prefix: "#{dice_count}d")
      {inline_keyboard: inline_keyboard}
    else
      inline_keyboard = keyboard_options
      {inline_keyboard: inline_keyboard}
    end
  end

  def parse_mode
    "HTML"
  end

  def keyboard_options(callback_prefix: "")
    options = (1..20).map do |dice|
      {
        text: dice.to_s,
        callback_data: "roll_formula:#{callback_prefix}#{dice}"
      }
    end
    option_lines = options.in_groups_of(5, false)
    option_lines.prepend([text: "20", callback_data: "roll_formula:#{callback_prefix}20"])
    option_lines.append([text: "100", callback_data: "roll_formula:#{callback_prefix}100"])
    option_lines
  end

  def invalid_input?
    is_invalid = roll_formula.present? && parsed_dice_formula.nil?
    return true if is_invalid
    parsed_dice_formula.present? && (dice_count.to_i > 100 || dice_value.to_i > 100)
  end

  def full_roll_formula?
    dice_value && dice_count
  end

  def partial_roll_formula?
    dice_count && dice_value.nil?
  end

  def dice_count
    parsed_dice_formula.try(:[], :dice_count).nil? ? nil : parsed_dice_formula[:dice_count].to_i
  end

  def dice_value
    parsed_dice_formula.try(:[], :dice_value).nil? ? nil : parsed_dice_formula[:dice_value].to_i
  end

  def parsed_dice_formula
    @parsed_dice_formula ||= roll_formula&.match(ROLL_FORMULA_REGEXP)
  end
end
