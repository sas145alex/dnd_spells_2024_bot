class Telegram::ProcessAdviceJob < ApplicationJob
  def perform(text, from: {}, message_time: nil)
    author = build_author(from)
    message_timestamp = timestamp(message_time)
    Advice.create(text: text, author: author, timestamp: message_timestamp)
  end

  private

  def build_author(from)
    author = []
    author << "ID: #{from["id"]}" if from["id"]
    author << from["first_name"]
    author << from["last_name"]
    author << from["username"]
    author.compact.join(" - ")
  end

  def timestamp(unix_timestamp)
    return nil if unix_timestamp.blank?
    return unless unix_timestamp.is_a?(Integer)

    Time.at(unix_timestamp)
  end
end
