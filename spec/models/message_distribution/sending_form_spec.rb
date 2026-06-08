require "rails_helper"

RSpec.describe MessageDistribution::SendingForm do
  subject(:form) { described_class.new }

  around do |example|
    Timecop.freeze(Time.parse("2026-06-08")) do
      example.run
    end
  end

  it { is_expected.to be_a(ApplicationForm) }

  it "is never persisted" do
    expect(form.persisted?).to be(false)
  end

  it "is read only" do
    expect(form.readonly?).to be(true)
  end

  describe "#send_to_users" do
    it { expect(form.send_to_users).to be(true) }
  end

  describe "#send_to_chats" do
    it "defaults to false (do not broadcast to chats by default)" do
      expect(form.send_to_chats).to be(false)
    end
  end

  describe "#only_active" do
    it { expect(form.only_active).to be(true) }
  end

  describe "#active_since" do
    it "defaults to 60 days ago" do
      expect(form.active_since).to eq(60.days.ago)
    end
  end

  describe "#min_command_count" do
    it { expect(form.min_command_count).to be_nil }
  end

  describe "#test_sending" do
    it { expect(form.test_sending).to be(false) }
  end

  describe "#test_telegram_user_ids" do
    it { expect(form.test_telegram_user_ids).to eq([]) }
  end

  describe "#test_telegram_chat_ids" do
    it { expect(form.test_telegram_chat_ids).to eq("") }
  end
end
