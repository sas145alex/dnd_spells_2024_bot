bots_config = {
  default: {
    async: Rails.env.production?,
    token: ENV.fetch("BOT_TOKEN", "token"),
    username: ENV.fetch("BOT_NAME", "name"),
  }.tap do |hash|
    hash[:server] = "http://localhost:3000/" if Rails.env.local?
  end
}

Telegram.bots_config = bots_config
