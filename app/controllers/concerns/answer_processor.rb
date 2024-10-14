module AnswerProcessor
  extend ActiveSupport::Concern

  def process_answer_messages(answer_messages = [])
    answer_messages.each do |message|
      sleep(0.1)
      case message[:type]
      when :edit
        edit_message :text, message[:answer]
      when :reply
        reply_with :message, message[:answer]
      else
        respond_with :message, message[:answer]
      end
    end
  end
end
