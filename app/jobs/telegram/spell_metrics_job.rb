class Telegram::SpellMetricsJob < ApplicationJob
  def perform(spell_id)
    spell = Spell.find_by(id: spell_id)
    return unless spell
    spell.transaction do
      spell.increment(:requested_count)
      spell.save!
    end
  end
end
