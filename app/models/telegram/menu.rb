module Telegram
  # Source of truth for the bot's slash-menu (Bot API setMyCommands), pushed by
  # `rake telegram:bot:set_commands` — the menu is versioned here instead of edited in BotFather.
  class Menu
    COMMANDS = [
      {command: "roll", description: "🎲 Кинуть кость"},
      {command: "search", description: "🔎 Поиск по справочнику"},
      {command: "wild_magic", description: "💥 Дикая магия"},
      {command: "sections", description: "📚 Все разделы"},
      {command: "favorites", description: BotCommands::FavoritesList::HEADER},
      {command: "feedback", description: "💬 Предложить исправление либо связаться"},
      {command: "about", description: "Информация о боте"}
    ].freeze

    # Production configures async: "BotRequestJob", so an unwrapped call would only be enqueued and
    # its result invisible; async(false) makes the task report what Telegram actually answered.
    def self.set!
      Telegram.bot.async(false) { Telegram.bot.set_my_commands(commands: COMMANDS) }
    end
  end
end
