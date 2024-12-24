if defined?(::Telegram::Bot::Client)
  class Telegram::Bot::Client
    def external_id
      @external_id ||= token.split(":").first.to_i
    end
  end
end
