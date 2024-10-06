class RenameCharacterAbilityToCharacteristic < ActiveRecord::Migration[7.2]
  def up
    rename_table :character_abilities, :characteristics

    data_migrate_up
  end

  def down
    rename_table :characteristics, :character_abilities

    data_migrate_down
  end

  private

  def data_migrate_up
    sql = <<~SQL.squish
      UPDATE mentions 
      SET another_mentionable_type = 'Characteristic'
      WHERE another_mentionable_type = 'CharacterAbility'
    SQL
    execute(sql)

    sql = <<~SQL.squish
      UPDATE mentions 
      SET mentionable_type = 'Characteristic'
      WHERE mentionable_type = 'CharacterAbility'
    SQL
    execute(sql)

    sql = <<~SQL.squish
      UPDATE segments 
      SET resource_type = 'Characteristic'
      WHERE resource_type = 'CharacterAbility'
    SQL
    execute(sql)

    sql = <<~SQL.squish
      UPDATE segments 
      SET attribute_resource_type = 'Characteristic'
      WHERE attribute_resource_type = 'CharacterAbility'
    SQL
    execute(sql)
  end

  def data_migrate_down
    sql = <<~SQL.squish
      UPDATE mentions 
      SET another_mentionable_type = 'CharacterAbility'
      WHERE another_mentionable_type = 'Characteristic'
    SQL
    execute(sql)

    sql = <<~SQL.squish
      UPDATE mentions 
      SET mentionable_type = 'CharacterAbility'
      WHERE mentionable_type = 'Characteristic'
    SQL
    execute(sql)

    sql = <<~SQL.squish
      UPDATE segments 
      SET resource_type = 'CharacterAbility'
      WHERE resource_type = 'Characteristic'
    SQL
    execute(sql)

    sql = <<~SQL.squish
      UPDATE segments 
      SET attribute_resource_type = 'CharacterAbility'
      WHERE attribute_resource_type = 'Characteristic'
    SQL
    execute(sql)
  end
end
