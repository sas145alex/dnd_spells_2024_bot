require "rails_helper"

RSpec.describe AnswerProcessor do
  subject(:process) { dummy.process_answer_messages([{type: type, answer: answer}]) }

  # A bare host object that includes the concern and stubs the Telegram dispatch helpers
  # (respond_with / reply_with / edit_message) the real controller supplies.
  let(:dummy_class) do
    Class.new do
      include AnswerProcessor
      def sleep(*) = nil
      def respond_with(*) = nil
      def reply_with(*) = nil
      def edit_message(*) = nil
    end
  end
  let(:dummy) { dummy_class.new }
  let(:fallback) { AnswerProcessor::EMPTY_TEXT_FALLBACK }
  let(:type) { :message }
  let(:answer) { {text: text, reply_markup: {inline_keyboard: []}, parse_mode: "HTML"} }
  let(:text) { "" }

  before do
    allow(dummy).to receive(:respond_with)
    allow(dummy).to receive(:reply_with)
    allow(dummy).to receive(:edit_message)
  end

  context "when the text is blank" do
    it "substitutes the fallback on a respond_with message" do
      process

      expect(dummy).to have_received(:respond_with).with(:message, hash_including(text: fallback))
    end

    context "and the text is nil" do
      let(:text) { nil }

      it "still substitutes the fallback" do
        process

        expect(dummy).to have_received(:respond_with).with(:message, hash_including(text: fallback))
      end
    end

    context "and the message is a reply" do
      let(:type) { :reply }

      it "substitutes the fallback" do
        process

        expect(dummy).to have_received(:reply_with).with(:message, hash_including(text: fallback))
      end
    end

    context "and the message is an edit" do
      let(:type) { :edit }

      it "substitutes the fallback" do
        process

        expect(dummy).to have_received(:edit_message).with(:text, hash_including(text: fallback))
      end
    end
  end

  context "when the text is present" do
    let(:text) { "Настоящее описание" }

    it "passes the text through unchanged" do
      process

      expect(dummy).to have_received(:respond_with).with(:message, hash_including(text: "Настоящее описание"))
    end
  end
end
