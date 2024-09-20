bots_config = {
  default: {
    async: Rails.env.production? ? "BotRequestJob" : false,
    token: ENV.fetch("BOT_TOKEN"),
    username: ENV.fetch("BOT_NAME")
  }.tap do |hash|
    hash[:server] = "http://localhost:3000/" if ENV["BOT_USE_LOCALHOST"]
  end
}

Telegram.bots_config = bots_config

Rails.application.config.to_prepare do
  BotRequestJob.client_class = Telegram::Bot::Client
end
