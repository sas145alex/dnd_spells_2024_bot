Telegram.bots_config = {
  default: ENV.fetch("BOT_TOKEN", "token"),
  dnd_spells_2024_bot: {
    async: Rails.env.production?,
    token: ENV.fetch("BOT_TOKEN", "token"),
    username: ENV.fetch("BOT_NAME", "name"),
    server: ENV.fetch("BOT_SERVER_URL", "http://localhost:3000/")
  }
}
