# Sentry `before_send` hook. Sentry's default grouping keys on the exception class and the in-app
# stacktrace and ignores the message, so every `Telegram::Bot::Error` re-raised from the single
# `super` frame in BotRequestJob collapses into one issue (e.g. TOPIC_CLOSED and "message text is
# empty" merged). Adding the normalized message to the fingerprint splits distinct Telegram API
# errors into their own issues, while `"{{ default }}"` keeps Sentry's default grouping as the base
# (so nothing that was correctly separate gets merged).
module TelegramErrorFingerprint
  module_function

  # Callable assigned to `config.before_send`; must respond to .call(event, hint) and return event.
  def call(event, hint)
    fingerprint = fingerprint_for(hint && hint[:exception])
    event.fingerprint = fingerprint if fingerprint
    event
  end

  def fingerprint_for(exception)
    return unless defined?(::Telegram::Bot::Error) && exception.is_a?(::Telegram::Bot::Error)

    ["{{ default }}", exception.class.name, normalize(exception.message)]
  end

  def normalize(message)
    message.to_s.downcase.gsub(/\d+/, "N").gsub(/\s+/, " ").strip[0, 120]
  end
end
