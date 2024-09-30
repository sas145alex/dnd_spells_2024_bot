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
end
