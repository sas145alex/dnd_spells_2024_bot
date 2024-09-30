class Telegram::SpellMetricsJob < ApplicationJob
  def perform(spell_gid:)
    spell = GlobalID::Locator.locate(spell_gid, only: Spell)
    return unless spell
    spell.transaction do
      spell.increment(:requested_count)
      spell.save!
    end
  end
end
