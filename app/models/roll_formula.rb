class RollFormula
  MAX_VALUE = 100
  MAX_MODIFIER = 10_000
  BASE_ROLL_REGEXP = /^(?<dice_count>\d+)(?<second_part>\w(?<dice_value>\d+))/
  MOD_ROLL_REGEXP = /(?<mod_sign>[\+\-])?(?<mod_value>\d+)?/
  ROLL_FORMULA_REGEXP = Regexp.new(BASE_ROLL_REGEXP.source + MOD_ROLL_REGEXP.source)

  def initialize(roll_formula = "")
    @roll_formula = roll_formula
  end

  def valid?
    return false if dice_count.blank? || dice_count < 1
    return false if dice_value.blank? || dice_value < 1
    return false if dice_count > MAX_VALUE || dice_value > MAX_VALUE
    return false if mod_value > MAX_MODIFIER

    true
  end

  def invalid?
    !valid?
  end

  def dice_count
    parsed_formula.try(:[], :dice_count).nil? ? nil : parsed_formula[:dice_count].to_i
  end

  def dice_value
    parsed_formula.try(:[], :dice_value).nil? ? nil : parsed_formula[:dice_value].to_i
  end

  def mod_value
    parsed_formula[:mod_value].to_i
  end

  def mod_sign
    (parsed_formula[:mod_sign] || "+").to_s.to_sym
  end

  def roll_result
    text = <<~HTML.chomp
      <b>Бросок:</b> 🎲 #{roll_formula}
      <b>Все результаты:</b> #{rolls.sort.join(", ")}
      #{modifier_text}
      #{advantage_text}
      #{disadvantage_text}
      <b>Итог:</b> #{apply_modifier(rolls_sum)}
    HTML
    text.squeeze("\n")
  end

  private

  attr_reader :roll_formula

  def parsed_formula
    @parsed_formula ||= roll_formula.match(ROLL_FORMULA_REGEXP)
  end

  def rolls
    @rolls ||= (1..dice_count).to_a.map { rand(1..dice_value) }
  end

  def rolls_sum
    rolls.sum
  end

  def apply_modifier(int)
    (mod_sign == :+) ? int + mod_value : int - mod_value
  end

  def modifier_text
    return "" if mod_value.zero?

    <<~HTML
      <b>Сумма без модификатора:</b> #{rolls_sum}
      <b>Модификатор:</b> #{mod_sign}#{mod_value}
    HTML
  end

  def advantage_text
    return "" unless advantage_or_disadvantage?

    "<b>Преимущество:</b> 🟢 #{apply_modifier(rolls.max)}"
  end

  def disadvantage_text
    return "" unless advantage_or_disadvantage?

    "<b>Помеха:</b> 🔴 #{apply_modifier(rolls.min)}"
  end

  def advantage_or_disadvantage?
    dice_count == 2 && dice_value == 20
  end
end
