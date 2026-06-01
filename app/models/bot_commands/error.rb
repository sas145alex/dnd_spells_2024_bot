module BotCommands
  class Error < BaseCommand
    class TestError < StandardError; end

    DEFAULT_MESSAGE = "Test error triggered from /error command".freeze

    def call
      return [] unless user&.admin?

      raise TestError, message
    end

    def initialize(user:, input_value: nil)
      @user = user
      @input_value = input_value
    end

    private

    attr_reader :user, :input_value

    def message
      input_value.presence || DEFAULT_MESSAGE
    end
  end
end
