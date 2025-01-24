barbarians = [
  {title: "Путь Мирового Древа", original_title: "Path of the World Tree", description: "description"},
  {title: "Путь фанатика", original_title: "Path of the Zealot", description: "description"},
  {title: "Путь дикого сердца", original_title: "Path of the Wild Heart", description: "description"},
  {title: "Путь берсерка", original_title: "The Path of the Berserker", description: "description"}
]

bards = [
  {title: "Коллегия Доблести", original_title: "College of Valor", description: "description"},
  {title: "Коллегия Знаний", original_title: "College of Lore", description: "description"},
  {title: "Коллегия Очарований", original_title: "College of Glamour", description: "description"},
  {title: "Коллегия Танцев", original_title: "College of Dance", description: "description"}
]

clerics = [
  {title: "Домен Войны", original_title: "War Domain", description: "description"},
  {title: "Домен Обмана", original_title: "Trickery Domain", description: "description"},
  {title: "Домен Света", original_title: "Light Domain", description: "description"},
  {title: "Домен Жизни", original_title: "Life Domain", description: "description"}
]

rangers = [
  {title: "Охотник", original_title: "Hunter", description: "description"},
  {title: "Сумрачный охотник", original_title: "Gloom Stalker", description: "description"},
  {title: "Фейский странник", original_title: "Fey Wander", description: "description"},
  {title: "Повелитель зверей", original_title: "Beast Master", description: "description"}
]

druids = [
  {title: "Круг Звезд", original_title: "Circle of the Stars", description: "description"},
  {title: "Круг Земли", original_title: "Circle of the Land", description: "description"},
  {title: "Круг Луны", original_title: "Circle of the Moon", description: "description"},
  {title: "Круг Моря", original_title: "Circle of the Sea", description: "description"}
]

fighters = [
  {title: "Пси-воин", original_title: "Psi Warrior", description: "description"},
  {title: "Мистический рыцарь", original_title: "Eldritch Knight", description: "description"},
  {title: "Чемпион", original_title: "Champion", description: "description"},
  {title: "Мастер боевых искусств", original_title: "Battle Master", description: "description"}
]

warlocks = [
  {title: "Покровитель архифея", original_title: "Archfey Patron", description: "description"},
  {title: "Покровитель небожитель", original_title: "Celestial Patron", description: "description"},
  {title: "Покровитель исчадие", original_title: "Fiend Patron", description: "description"},
  {title: "Покровитель великий древний", original_title: "Great Old One Patron", description: "description"}
]

rogues = [
  {title: "Мистический ловкач", original_title: "Arcane Trickster", description: "description"},
  {title: "Убийца", original_title: "Assassin", description: "description"},
  {title: "Клинок души", original_title: "Soulknife", description: "description"},
  {title: "Вор", original_title: "Thief", description: "description"}
]

monks = [
  {title: "мастер Милосердия", original_title: "Warrior of Mercy", description: "description"},
  {title: "мастер Тени", original_title: "Warrior of Shadow", description: "description"},
  {title: "мастер Стихий", original_title: "Warrior of the Elements", description: "description"},
  {title: "мастер Открытой ладони", original_title: "Warrior of the Open Hand", description: "description"}
]

paladins = [
  {title: "клятва Преданности", original_title: "Oath of Devotion", description: "description"},
  {title: "клятва Славы", original_title: "Oath of Glory", description: "description"},
  {title: "клятва Древних", original_title: "Oath of the Ancients", description: "description"},
  {title: "клятва Мести", original_title: "Oath of Vengeance", description: "description"}
]

wizards = [
  {title: "Оградитель", original_title: "Abjurer", description: "description"},
  {title: "Прорицатель", original_title: "Diviner", description: "description"},
  {title: "Воплотитель", original_title: "Evoker", description: "description"},
  {title: "Иллюзионист", original_title: "Illusionist", description: "description"}
]

sorcerers = [
  {title: "Аберрантный разум", original_title: "Aberrant Sorcery", description: "description"},
  {title: "Заводная душа", original_title: "Clockwork Sorcery", description: "description"},
  {title: "Драконья кровь", original_title: "Draconic Sorcery", description: "description"},
  {title: "Дикая магия", original_title: "Wild Magic Sorcery", description: "description"}
]

klasses = [
  {title: "Варвар", original_title: "Barbarian", description: "description", subklasses: barbarians},
  {title: "Бард", original_title: "Bard", description: "description", subklasses: bards},
  {title: "Жрец", original_title: "Cleric", description: "description", subklasses: clerics},
  {title: "Следопыт", original_title: "Ranger", description: "description", subklasses: rangers},
  {title: "Друин", original_title: "Druid", description: "description", subklasses: druids},
  {title: "Воин", original_title: "Fighter", description: "description", subklasses: fighters},
  {title: "Колдун", original_title: "Warlock", description: "description", subklasses: warlocks},
  {title: "Плут", original_title: "Rogue", description: "description", subklasses: rogues},
  {title: "Монах", original_title: "Monk", description: "description", subklasses: monks},
  {title: "Паладин", original_title: "Paladin", description: "description", subklasses: paladins},
  {title: "Волшебник", original_title: "Wizard", description: "description", subklasses: wizards},
  {title: "Чародей", original_title: "Sorcerer", description: "description", subklasses: sorcerers},
  {title: "Изобретатель [UA24]", original_title: "Artificer [UA24]", description: "description", subklasses: []}
]

pp "Performing - #{__FILE__}"

pp "Before count = #{CharacterKlass.count}"

klasses.each do |attr|
  base_klass = CharacterKlass.find_or_create_by!(original_title: attr[:original_title]) do |record|
    record.title = attr[:title]
    record.description = attr[:description]
  end

  if attr[:subklasses].present?
    attr[:subklasses].each do |subklass_attrs|
      CharacterKlass.find_or_create_by!(parent_klass: base_klass, original_title: subklass_attrs[:original_title]) do |record|
        record.title = subklass_attrs[:title]
        record.description = subklass_attrs[:description]
      end
    end
  end
end

pp "After count = #{CharacterKlass.count}"
