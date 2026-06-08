class MessageDistribution
  # Processes a distribution's pending deliveries in throttled batches.
  # Resumable: only ever picks up `pending` rows, so a crash/retry continues
  # where it left off without re-sending. Runs on a dedicated queue so a large
  # broadcast does not starve interactive bot traffic.
  class DeliveryJob < ApplicationJob
    queue_as :distributions

    # Telegram caps a bot at ~30 messages/sec globally (shared with interactive
    # webhook replies). Only one broadcast may run at a time so this per-job
    # throttle IS the global send rate; concurrent broadcasts would multiply it
    # and trip flood limits. `duration` must exceed the longest broadcast so the
    # concurrency semaphore is not expired mid-run.
    limits_concurrency to: 1, key: "telegram_broadcast", duration: 2.hours

    BATCH_SIZE = 500
    # ~10 msg/sec leaves ample headroom under Telegram's ~30/sec global limit.
    THROTTLE_SECONDS = 0.10

    retry_on StandardError, attempts: 3, wait: 5.seconds

    def perform(distribution)
      return if distribution.completed?

      distribution.start_sending!

      loop do
        batch = distribution.deliveries.pending.includes(:recipient).limit(BATCH_SIZE).to_a
        break if batch.empty?

        text = distribution.telegram_text
        batch.each do |delivery|
          MessageDistribution::DeliverOne.call(delivery: delivery, text: text)
          sleep(THROTTLE_SECONDS) if Rails.env.production?
        end

        distribution.refresh_counts!
      end

      distribution.complete!
    end
  end
end
