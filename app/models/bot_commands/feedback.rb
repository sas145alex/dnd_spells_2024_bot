module BotCommands
  class Feedback < BaseCommand
    def self.payload_can_be_accepted?(payload)
      message = message_from_payload(payload)
      message.present? && !message.start_with?("/")
    end

    def self.message_from_payload(payload)
      payload["caption"].presence || payload["text"].presence
    end

    def self.external_id_from_payload(payload)
      payload.dig("from", "id")
    end

    def self.process(payload)
      message = message_from_payload(payload)
      external_user_id = external_id_from_payload(payload)
      feedback_record = ::Feedback.create!(
        external_user_id: external_user_id,
        payload: payload,
        message: message
      )
      feedback_record.notify_later
    end
  end
end
