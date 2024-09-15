bots_config = {
  default: {
    async: Rails.env.production?,
    token: ENV.fetch("BOT_TOKEN"),
    username: ENV.fetch("BOT_NAME")
  }.tap do |hash|
    hash[:server] = "http://localhost:3000/" if ENV["BOT_USE_LOCALHOST"]
  end
}

Telegram.bots_config = bots_config
