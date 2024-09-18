module ApplicationHelper
  def markdown_to_html(text)
    options = {
      filter_html: true,
      hard_wrap: true,
      link_attributes: {rel: "nofollow", target: "_blank"},
      space_after_headers: true,
      fenced_code_blocks: true
    }

    renderer = Redcarpet::Render::HTML.new(options)
    markdown = Redcarpet::Markdown.new(renderer)

    markdown.render(text).html_safe
  end
end
