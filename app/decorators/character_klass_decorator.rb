class CharacterKlassDecorator < ApplicationDecorator
  FILE_PREFIX = "klass_tables"

  # @return [nil, String]
  def self.build_link_to_ability_table(klass_title)
    filename = klass_title.parameterize.underscore
    filepath = Rails.root.join("public", FILE_PREFIX, "#{filename}.png")

    return unless File.exist?(filepath)

    h.asset_path("#{FILE_PREFIX}/#{filename}.png", skip_pipeline: true)
  end

  def self.links_store
    @links_store ||= begin
      klasses = CharacterKlass.pluck(:original_title).map { _1.to_s.strip.downcase }
      hash = {}
      klasses.each do |klass_title|
        link = build_link_to_ability_table(klass_title)
        next if link.blank?
        hash[klass_title] = link
      end
      hash
    end
  end

  def title
    if object.base_klass?
      object.title
    else
      "#{object.parent_klass.title} - #{object.title}"
    end
  end

  def description_for_telegram
    description_with_link_to_klass_table(super)
  end

  private

  def description_with_link_to_klass_table(text)
    klass_name = original_title.downcase.to_s
    url_to_file = self.class.links_store[klass_name]

    return text if url_to_file.blank?

    link = h.link_to("abilities", url_to_file)
    [text, link].join("\n\n")
  end
end
