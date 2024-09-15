class Services::ImportSpells
  SPELL_BREAK_LINE = "---"

  def self.call(...)
    new(...).call
  end

  def call
    title = ""
    description = ""

    File.readlines(file_path).each do |line|
      if line.chomp == SPELL_BREAK_LINE
        Spell.create(
          title: title,
          description: description,
          created_by: created_by
        )
        title = ""
        description = ""

        next
      end

      title = line.delete("*") if title.blank? && line.present?
      description.concat(line)
    end

    Spell.create(
      title: title,
      description: description,
      created_by: created_by
    )
  end

  def initialize(file_path: "db/seeds/spells.md", created_by: AdminUser.system_user)
    @file_path = file_path
    @created_by = created_by
  end

  private

  attr_reader :file_path
  attr_reader :created_by
end
