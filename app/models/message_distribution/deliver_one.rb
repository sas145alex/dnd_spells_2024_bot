class MessageDistribution
  # Sends a single MessageDelivery and records the outcome on it.
  # Never raises: every Telegram error is mapped to a failure reason.
  class DeliverOne < ApplicationOperation
    MAX_FLOOD_RETRIES = 1
    DEFAULT_FLOOD_WAIT = 5
    MAX_FLOOD_WAIT = 60

    def initialize(delivery:, text: nil)
      @delivery = delivery
      @text = text
    end

    def call
      deliver_with_flood_retry
      delivery.update!(status: :sent, sent_at: Time.current, error_reason: nil, error_message: nil)
      true
    rescue Telegram::Bot::Forbidden => e
      fail_delivery(forbidden_reason(e), e)
      mark_recipient_removed
      false
    rescue Telegram::Bot::NotFound => e
      fail_delivery(:chat_not_found, e)
      mark_recipient_removed
      false
    rescue Telegram::Bot::Error => e
      handle_generic_error(e)
      false
    end

    private

    attr_reader :delivery

    def text
      @text ||= delivery.message_distribution.telegram_text
    end

    # Retry a flood (429) once after waiting Telegram's retry_after, then give up
    # and let the outer rescue record it. Bounded so a persistent limit can't loop.
    def deliver_with_flood_retry
      attempts = 0
      begin
        send_message
      rescue Telegram::Bot::Error => e
        raise unless flood?(e) && attempts < MAX_FLOOD_RETRIES

        attempts += 1
        sleep(flood_wait(e)) if Rails.env.production?
        retry
      end
    end

    # Force a synchronous request: in production the bot is configured to send
    # asynchronously via BotRequestJob, which would discard the per-recipient
    # result we need to record here.
    def send_message
      Telegram.bot.async(false) do
        Telegram.bot.send_message(
          chat_id: delivery.external_id,
          text: text,
          parse_mode: "HTML"
        )
      end
    end

    def handle_generic_error(error)
      if flood?(error)
        fail_delivery(:flood_wait, error)
      else
        fail_delivery(:other, error)
        Sentry.capture_exception(error)
      end
    end

    def flood?(error)
      error.message.match?(/too many requests|retry after/i)
    end

    def flood_wait(error)
      seconds = error.message[/retry after (\d+)/i, 1].to_i
      seconds = DEFAULT_FLOOD_WAIT if seconds <= 0
      [seconds, MAX_FLOOD_WAIT].min
    end

    def forbidden_reason(error)
      error.message.match?(/deactivated/i) ? :deactivated : :blocked
    end

    def fail_delivery(reason, error)
      delivery.update!(status: :failed, error_reason: reason, error_message: error.message)
    end

    def mark_recipient_removed
      case delivery.recipient_type
      when "TelegramUser"
        TelegramUser::MarkAsRemoved.call(bot: nil, chat_id: delivery.external_id)
      when "TelegramChat"
        TelegramChat::MarkAsRemoved.call(bot: nil, chat_id: delivery.external_id)
      end
    end
  end
end
