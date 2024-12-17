class MessageDistribution
  class Send < ApplicationOperation
    BATCH_SIZE = 200

    include ActiveModel::Validations

    validate :check_users

    # {"telegram_user_ids"=>[""], "active_since"=>"2024-08-19 11:01", "test_sending"=>"1"}
    def initialize(distribution:, options: {})
      @distribution = distribution
      @options = options
    end

    def call
      return false if invalid?

      users.in_batches(of: BATCH_SIZE).each do |user_batch|
        user_batch.each do |user|
          process_user(user)
        end
        sleep(2) if Rails.env.production?
      end

      distribution.update(last_sent_at: Time.current) unless test_sending?

      true
    end

    private

    attr_reader :distribution
    attr_reader :options

    def process_user(user)
      Telegram.bot.send_message(
        chat_id: user.external_id,
        text: text,
        parse_mode: "HTML"
      )
    rescue Telegram::Bot::Error, Telegram::Bot::Forbidden => _e
      nil
    end

    def text
      @text ||= FormatChanger.markdown_to_telegram_markdown(distribution.content)
    end

    def users
      @users ||= user_dataset
    end

    def user_dataset
      scope = TelegramUser.all
      scope = scope.where(external_id: telegram_user_ids) if telegram_user_ids.present?
      if last_seen_at.present?
        scope = scope.where("last_seen_at >= :last_seen_at OR last_seen_at IS NULL", last_seen_at: last_seen_at)
      end
      scope
    end

    def last_seen_at
      @last_seen_at ||= begin
        datetime = options["active_since"] || nil
        parsed_datetime = DateTime.parse(datetime) if datetime.is_a?(String)
        parsed_datetime
      end
    end

    def telegram_user_ids
      @telegram_user_ids ||= (options["telegram_user_ids"] || []).compact_blank.map(&:to_i)
    end

    def test_sending?
      @test_sending ||= begin
        value = options["test_sending"] || true
        ActiveModel::Type::Boolean.new.cast(value)
      end
    end

    def check_users
      return if users.count >= 1

      errors.add(:base, "Пустая выборка юзеров")
    end

    def check_text
      return if text.size > 1

      errors.add(:base, "Пустой текст")
    end
  end
end
