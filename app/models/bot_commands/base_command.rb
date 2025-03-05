module BotCommands
  class BaseCommand < ApplicationOperation
    SEARCH_BY_CHARACTERISTIC_SUBCOMMAND = {text: "Поиск по хар-ке", value: "search_by_characteristic"}.freeze

    private

    def invalid_input
      {
        text: "Невалидный ввод",
        reply_markup: {},
        parse_mode: parse_mode
      }
    end

    def go_back_button
      {
        text: "Назад",
        callback_data: "go_back:go_back"
      }
    end

    def keyboard_mentions_options(object)
      return [] unless object.respond_to?(:mentions)

      object.mentions.map do |mention|
        {
          text: mention.another_mentionable.decorate.title,
          callback_data: "pick_mention:#{mention.id}"
        }
      end
    end

    def keyboard_options(variants, forced_callback_prefix: nil)
      prefix = forced_callback_prefix || callback_prefix
      variants.map do |variant|
        {
          text: variant.title,
          callback_data: "#{prefix}:#{variant.to_global_id}"
        }
      end
    end

    def callback_prefix
      raise NotImplementedError
    end

    def search_by_characteristic_subcommand
      {
        text: SEARCH_BY_CHARACTERISTIC_SUBCOMMAND[:text],
        callback_data: "#{callback_prefix}:#{SEARCH_BY_CHARACTERISTIC_SUBCOMMAND[:value]}"
      }
    end

    def characteristic_search_selected?
      input_value == SEARCH_BY_CHARACTERISTIC_SUBCOMMAND[:value]
    end

    def selected_object
      @selected_object ||= GlobalID::Locator.locate(gid_value)&.decorate
    end

    def gid_value
      input_value
    end

    def parse_mode
      "HTML"
    end

    def locale
      "ru"
    end
  end
end
