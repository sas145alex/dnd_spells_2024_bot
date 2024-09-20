class BotCommand::About < ApplicationOperation
  DEFAULT_TEXT = "Welcome!"

  def call
    {
      text: text,
      reply_markup: {},
      parse_mode: "HTML"
    }
  end

  private

  def text
    message = command_record&.description || DEFAULT_TEXT
    FormatChanger.markdown_to_telegram_markdown(message)
  end

  def command_record
    ::BotCommand.about
  end
end
