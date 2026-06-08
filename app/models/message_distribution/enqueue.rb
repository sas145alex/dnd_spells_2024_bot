class MessageDistribution
  class Enqueue < ApplicationOperation
    include ActiveModel::Validations

    INSERT_BATCH_SIZE = 1000

    validate :check_sendable
    validate :check_audience_present

    def initialize(distribution:)
      @distribution = distribution
    end

    def call
      return false if invalid?

      distribution.transaction do
        materialize_recipients
        distribution.update!(status: :queued, recipients_count: distribution.deliveries.count)
      end

      MessageDistribution::DeliveryJob.perform_later(distribution)

      true
    end

    private

    attr_reader :distribution

    def audience
      @audience ||= MessageDistribution::Audience.new(distribution: distribution)
    end

    def materialize_recipients
      insert_recipients(audience.users, "TelegramUser")
      insert_recipients(audience.chats, "TelegramChat")
    end

    def insert_recipients(scope, type)
      now = Time.current
      scope.in_batches(of: INSERT_BATCH_SIZE) do |batch|
        rows = batch.pluck(:id, :external_id).map do |id, external_id|
          {
            message_distribution_id: distribution.id,
            recipient_type: type,
            recipient_id: id,
            external_id: external_id,
            status: "pending",
            created_at: now,
            updated_at: now
          }
        end
        MessageDelivery.insert_all(rows) if rows.any?
      end
    end

    def check_sendable
      return if distribution.sendable?

      errors.add(:base, "Рассылка уже была отправлена")
    end

    def check_audience_present
      return if audience.total.positive?

      errors.add(:base, "Пустая выборка юзеров и чатов")
    end
  end
end
