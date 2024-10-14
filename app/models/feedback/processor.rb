class Feedback::Processor < ApplicationOperation
  def initialize(payload)
    @payload = payload
  end

  def call
    Feedback.create(
      text: text,
      author: author,
      timestamp: timestamp
    )
  end

  private

  attr_reader :payload

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
