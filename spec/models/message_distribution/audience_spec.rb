require "rails_helper"

RSpec.describe MessageDistribution::Audience do
  describe "#users" do
    subject(:users) { described_class.new(distribution: distribution).users }

    let(:distribution) do
      create(:message_distribution,
        send_to_users: true,
        send_to_chats: false,
        only_active: only_active,
        active_since: active_since,
        min_command_count: min_command_count)
    end
    let(:only_active) { true }
    let(:active_since) { nil }
    let(:min_command_count) { nil }

    let!(:active_user) do
      create(:telegram_user, bot_removed_at: nil, last_seen_at: 1.day.ago, command_requested_count: 10)
    end
    let!(:removed_user) do
      create(:telegram_user, bot_removed_at: 1.day.ago, last_seen_at: 1.day.ago, command_requested_count: 10)
    end

    it "excludes removed users by default" do
      expect(users).to include(active_user)
      expect(users).not_to include(removed_user)
    end

    context "when only_active is false" do
      let(:only_active) { false }

      it { is_expected.to include(active_user, removed_user) }
    end

    context "with an active_since filter" do
      let(:active_since) { 7.days.ago }
      let!(:stale_user) { create(:telegram_user, last_seen_at: 30.days.ago) }

      it "keeps recently-seen users and drops stale ones" do
        expect(users).to include(active_user)
        expect(users).not_to include(stale_user)
      end
    end

    context "with a min_command_count filter" do
      let(:min_command_count) { 5 }
      let!(:quiet_user) { create(:telegram_user, command_requested_count: 1) }

      it "keeps engaged users and drops quiet ones" do
        expect(users).to include(active_user)
        expect(users).not_to include(quiet_user)
      end
    end

    context "when send_to_users is false" do
      let(:distribution) { create(:message_distribution, send_to_users: false) }

      it { is_expected.to be_empty }
    end
  end

  describe "#chats" do
    subject(:chats) { described_class.new(distribution: distribution).chats }

    let(:distribution) { create(:message_distribution, send_to_chats: send_to_chats, only_active: true) }
    let(:send_to_chats) { true }

    let!(:active_chat) { create(:telegram_chat, bot_removed_at: nil) }
    let!(:removed_chat) { create(:telegram_chat, bot_removed_at: 1.day.ago) }

    it "returns only active chats" do
      expect(chats).to include(active_chat)
      expect(chats).not_to include(removed_chat)
    end

    context "when send_to_chats is false" do
      let(:send_to_chats) { false }

      it { is_expected.to be_empty }
    end
  end
end
