creds = Rails.application.credentials.bot || {}
bots_config = {
  default: {
    async: Rails.env.production? ? "BotRequestJob" : false,
    token: ENV["BOT_TOKEN"] || creds.dig(:token) || "bot_token",
    username: ENV["BOT_NAME"] || creds.dig(:name) || "bot_name"
  }.tap do |hash|
    hash[:server] = "http://localhost:3000/" if ENV["BOT_USE_LOCALHOST"]
  end
}

Telegram.bots_config = bots_config

Rails.application.config.to_prepare do
  BotRequestJob.client_class = Telegram::Bot::Client
end
