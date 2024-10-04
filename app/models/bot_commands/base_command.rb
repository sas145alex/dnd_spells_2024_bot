module BotCommands
  class BaseCommand < ApplicationOperation
    SEARCH_BY_ABILITY_SUBCOMMAND = {text: "Поиск по хар-ке", value: "search_by_ability"}.freeze
  end
end
