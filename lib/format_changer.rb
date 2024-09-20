module FormatChanger
  def self.markdown_to_html(text)
    options = {
      filter_html: true,
      hard_wrap: true,
      link_attributes: {rel: "nofollow", target: "_blank"},
      space_after_headers: true,
      fenced_code_blocks: true
    }

    renderer = Redcarpet::Render::HTML.new(options)
    markdown = Redcarpet::Markdown.new(renderer)

    markdown.render(text)
  end

  def self.markdown_to_telegram_markdown(text)
    renderer = Renderers::TelegramHTML.new
    markdown = Redcarpet::Markdown.new(renderer)
    markdown.render(text)
  end
end
