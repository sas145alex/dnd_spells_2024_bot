class TelegramController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::MessageContext
  include Telegram::Bot::UpdatesController::Session

  MAX_VARIANTS_SIZE = 7
  SEARCH_VALUE_MIN_LENGTH = 3

  def message(*args)
    respond_with :message, text: "Вы ввели - #{payload["text"]}"
  end

  def stop_search!(*args)
    set_last_variants([])

    reply_markup = {
      remove_keyboard: true
    }

    respond_with :message,
      text: "Поиск окончен",
      reply_markup: reply_markup
  end

  def start_search_spell!(*args)
    save_context("provide_search_variants_for")

    respond_with :message, text: "Введите название искомого заклинания (не менее 3х символов)"
  end

  def provide_search_variants_for(*args)
    save_context("provide_search_variants_for")

    return if search_value_invalid?

    reply_markup = {}
    if provided_variant_picked?
      text = "Подробное описание для - #{payload["text"]}"
    else
      variants = fetch_new_variants

      if variants.present? && variants.size <= MAX_VARIANTS_SIZE
        text = "Найдено несколько вариантов. Выбери:"
        reply_markup = {
          keyboard: [variants, %w[/stop_search]],
          resize_keyboard: true,
          one_time_keyboard: false,
          selective: true
        }
      elsif variants.present?
        text = "Найдено слишком много вариантов"
      else
        text = "Не найдено никаких вариантов"
        reply_markup = {}
      end
    end

    respond_with :message, text: text, reply_markup: reply_markup
  end

  private

  def search_value_invalid?
    search_value.size < SEARCH_VALUE_MIN_LENGTH && last_variants.empty?
  end

  def search_value
    @search_value ||= payload["text"].chomp
  end

  def last_variants
    session[:last_variants]
  end

  def set_last_variants(value)
    session[:last_variants] = value
  end

  def provided_variant_picked?
    last_variants.present? && payload["text"].in?(last_variants)
  end

  def fetch_new_variants
    variants = %w[1 2 3]
    set_last_variants(variants)
    variants
  end
end
