class ApplicationDecorator < Draper::Decorator
  delegate_all

  # Draper builds a GID from the decorator class (gid://app/<Model>Decorator/<id>), which does
  # not round-trip through GlobalID::Locator.locate(..., only: <Model>). Keyboards are built from
  # decorated records, so callback_data must carry the underlying model's GID instead.
  def to_global_id(options = {})
    object.to_global_id(options)
  end
  alias_method :to_gid, :to_global_id

  def to_gid_param(options = {})
    object.to_gid_param(options)
  end

  def support_other_languages?
    description_for_telegram.present? && original_description_for_telegram.present?
  end

  def description_for_telegram
    return unless object.respond_to?(:description)
    return if object.description.blank?

    @description_for_telegram ||= h.markdown_to_telegram_markdown(object.description).strip
  end

  def original_description_for_telegram
    return unless object.respond_to?(:original_description)
    return if object.original_description.blank?

    @original_description_for_telegram ||= h.markdown_to_telegram_markdown(object.original_description).strip
  end

  def parse_mode_for_telegram
    "HTML"
  end

  def global_search_title
    "[#{object.class.model_name.human}] #{title.capitalize}"
  end

  def admin_mention_title
    title
  end
end
