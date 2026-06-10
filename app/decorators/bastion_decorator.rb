class BastionDecorator < ApplicationDecorator
  BASIC_GROUP_TITLE = "Базовые сооружения".freeze
  SPECIALIZED_GROUP_TITLE = "Специализированные".freeze

  def description_for_telegram
    return if object.description.blank?

    @description_for_telegram ||= telegram_card(title, object.description)
  end

  def original_description_for_telegram
    return if object.original_description.blank?

    @original_description_for_telegram ||= telegram_card(original_title, object.original_description)
  end

  private

  def telegram_card(header, body)
    <<~HTML.strip
      <b>#{header}</b>

      #{h.markdown_to_telegram_markdown(body).strip}
    HTML
  end
end
