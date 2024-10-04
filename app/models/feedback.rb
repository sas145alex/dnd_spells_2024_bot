class Feedback
  AQUA_COLOR = 1752220

  def self.create(text:, author: nil, timestamp: nil)
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
end
