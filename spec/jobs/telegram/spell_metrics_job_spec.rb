RSpec.describe Telegram::SpellMetricsJob do
  subject { described_class.perform_now(spell_gid: spell_gid) }

  context "when spell does not exist" do
    let(:spell_gid) { "bla" }

    it "does not raise en error" do
      expect { subject }.not_to raise_error
    end
  end

  context "when spell exists" do
    let(:spell_gid) { spell.to_global_id }
    let(:spell) { create(:spell) }

    it "changes counter" do
      expect { subject }.to change { spell.reload.requested_count }.from(0).to(1)
    end
  end

  # Callers pass the GID that the search keyboard built from a *decorated* spell. The decorator
  # must yield the underlying Spell GID, otherwise locate(only: Spell) returns nil and the
  # counter is silently never incremented for spells opened via search.
  context "when the gid comes from a decorated spell" do
    let(:spell) { create(:spell) }
    let(:spell_gid) { spell.decorate.to_global_id }

    it "changes counter" do
      expect { subject }.to change { spell.reload.requested_count }.from(0).to(1)
    end
  end
end
