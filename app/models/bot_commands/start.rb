module BotCommands
  class Start < BaseCommand
    def call
      {
        text: text,
        reply_markup: {},
        parse_mode: "HTML"
      }
    end

    private

    def text
      command_record.description_for_telegram
    end

    def command_record
      ::BotCommand.start.decorate
    end
  end
end
