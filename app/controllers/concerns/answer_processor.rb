module AnswerProcessor
  extend ActiveSupport::Concern

  # Telegram rejects sendMessage/editMessageText with empty text ("Bad Request: message text
  # is empty"). A blank description on a displayed record can leave a builder's answer with
  # text: nil, so substitute a generic fallback here as a last line of defence for every command.
  EMPTY_TEXT_FALLBACK = "Для этого элемента пока нет описания."

  def process_answer_messages(answer_messages = [])
    answer_messages.each do |message|
      sleep(0.1)
      answer = message[:answer]
      answer[:text] = EMPTY_TEXT_FALLBACK if answer.is_a?(Hash) && answer[:text].blank?
      case message[:type]
      when :edit
        edit_message :text, answer
      when :reply
        reply_with :message, answer
      else
        respond_with :message, answer
      end
    end
  end
end
