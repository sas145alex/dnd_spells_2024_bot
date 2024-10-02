attrs = [
  {title: "Сила", original_title: "Strength", description: "Strength"},
  {title: "Ловкость", original_title: "Dexterity", description: "Dexterity"},
  {title: "Телосложение", original_title: "Constitution", description: "Constitution"},
  {title: "Интелект", original_title: "Intelligence", description: "Intelligence"},
  {title: "Мудрость", original_title: "Wisdom", description: "Wisdom"},
  {title: "Харизма", original_title: "Charisma", description: "Charisma"}
]

pp "Performing - #{__FILE__}"

pp "Before count = #{CharacterAbility.count}"

attrs.each do |attr|
  CharacterAbility.find_or_create_by!(original_title: attr[:original_title]) do |character_ability|
    character_ability.title = attr[:title]
    character_ability.description = attr[:description]
    character_ability.published_at = Time.current
  end
end

pp "After count = #{CharacterAbility.count}"
