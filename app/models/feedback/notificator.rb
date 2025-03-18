class Feedback::Notificator < ApplicationOperation
  AQUA_COLOR = 1752220

  def self.notify!(text:, author: nil, timestamp: nil)
    formatted_timestamp = (timestamp || Time.current).iso8601
    embed = {
      title: "Feedback",
      description: text,
      timestamp: formatted_timestamp,
      color: AQUA_COLOR,
      author: {name: author}
    }

    notification_client.send_message(embeds: [embed])
  end

  def self.notification_client
    @notification_client ||= DiscordAPI::Client.new(webhook: ENV["ADVICE_WEBHOOK"])
  end

  def initialize(feedback)
    @feedback = feedback
  end

  def call
    self.class.notify!(
      text: text,
      author: author,
      timestamp: timestamp
    )
  end

  private

  attr_reader :feedback

  delegate :payload, to: :feedback

  def text
    payload["text"] || payload["caption"]
  end

  def author
    from = payload["from"]

    author = []
    author << "ID: #{from["id"]}" if from["id"]
    author << from["first_name"]
    author << from["last_name"]
    author << from["username"]
    author.compact.join(" - ")
  end

  def timestamp
    unix_timestamp = payload["date"]

    return nil if unix_timestamp.blank?
    return nil unless unix_timestamp.is_a?(Integer)

    Time.at(unix_timestamp)
  end
end
