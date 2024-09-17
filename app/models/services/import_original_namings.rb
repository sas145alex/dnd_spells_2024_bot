class Services::ImportOriginalNamings
  def self.call(...)
    new(...).call
  end

  def call
    CSV.foreach(file_path, headers: true) do |row|
      spell = Spell.find_by(title: row["rus"]&.chomp)
      next unless spell
      spell.update!(original_title: row["eng"]&.chomp)
    end

    true
  end

  def initialize(file_path: "db/seeds/spells_namings.csv")
    @file_path = file_path
  end

  private

  attr_reader :file_path
end
