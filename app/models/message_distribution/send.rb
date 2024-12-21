class MessageDistribution
  class Send < ApplicationOperation
    BATCH_SIZE = 200

    include ActiveModel::Validations

    validate :check_receivers_count

    # {"telegram_user_ids"=>[""], "active_since"=>"2024-08-19 11:01", "test_sending"=>"1"}
    def initialize(distribution:, options: {})
      @distribution = distribution
      @options = options
    end

    def call
      return false if invalid?

      users.in_batches(of: BATCH_SIZE).each do |records_batch|
        process_batch(records_batch)
      end

      chats.in_batches(of: BATCH_SIZE).each do |records_batch|
        process_batch(records_batch)
      end

      distribution.update(last_sent_at: Time.current) unless test_sending?

      true
    end

    private

    attr_reader :distribution
    attr_reader :options

    def process_batch(records_batch)
      records_batch.each do |record|
        process_chat(record)
      end

      sleep(2) if Rails.env.production?
    end

    # @param [TelegramChat, TelegramUser] chat
    def process_chat(chat)
      Telegram.bot.send_message(
        chat_id: chat.external_id,
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

    def chats
      @chats ||= chat_dataset
    end

    def user_dataset
      return TelegramUser.none unless send_to_users?

      scope = TelegramUser.all
      scope = scope.where(external_id: telegram_user_ids) if telegram_user_ids.present?
      if last_seen_at.present?
        scope = scope.where("last_seen_at >= :last_seen_at OR last_seen_at IS NULL", last_seen_at: last_seen_at)
      end
      scope
    end

    def chat_dataset
      return TelegramChat.none unless send_to_chats?

      scope = TelegramChat.active.all
      scope.where(external_id: telegram_chat_ids) if telegram_chat_ids.present?
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

    def send_to_users?
      value = options.fetch("send_to_users", true)
      ActiveModel::Type::Boolean.new.cast(value)
    end

    def telegram_chat_ids
      @telegram_chat_ids ||= (options["telegram_chat_ids"] || []).compact_blank.map(&:to_i)
    end

    def send_to_chats?
      value = options.fetch("send_to_chats", true)
      ActiveModel::Type::Boolean.new.cast(value)
    end

    def test_sending?
      @test_sending ||= begin
        value = options.fetch("test_sending", true)
        ActiveModel::Type::Boolean.new.cast(value)
      end
    end

    def check_receivers_count
      return if users.count != 0 || chats.count != 0

      errors.add(:base, "Пустая выборка юзеров и чатов")
    end

    def check_text
      return if text.size > 1

      errors.add(:base, "Пустой текст")
    end
  end
end
