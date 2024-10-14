class RollFormula
  MAX_VALUE = 100
  BASE_ROLL_REGEXP = /^(?<dice_count>\d+)(?<second_part>\w(?<dice_value>\d+))/
  MOD_ROLL_REGEXP = /(?<mod_sign>[\+\-])?(?<mod_value>\d+)?/
  ROLL_FORMULA_REGEXP = Regexp.new(BASE_ROLL_REGEXP.source + MOD_ROLL_REGEXP.source)

  def initialize(roll_formula = "")
    @roll_formula = roll_formula
  end

  def valid?
    return false if dice_value.blank? || dice_count.blank?
    return false if dice_count > MAX_VALUE || dice_value > MAX_VALUE

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

  private

  attr_reader :roll_formula

  def parsed_formula
    @parsed_formula ||= roll_formula.match(ROLL_FORMULA_REGEXP)
  end
end
