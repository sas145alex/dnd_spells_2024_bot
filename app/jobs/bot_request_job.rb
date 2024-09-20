class BotRequestJob < ApplicationJob
  include Telegram::Bot::Async::Job
end
