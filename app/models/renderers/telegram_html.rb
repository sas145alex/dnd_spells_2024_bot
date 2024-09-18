class Renderers::TelegramHTML < Redcarpet::Render::HTML
  # def block_code(code, language)
  #   "````#{language}\n#{code}\n````"
  # end

  # def block_quote(quote)
  #   long_quote = quote.chomp.gsub("\n", "\n>")
  #   ">#{long_quote}"
  # end

  # def block_html(raw_html)
  # end

  # def footnotes(content)
  #   content
  # end

  # def footnote_def(content, number)
  #   content
  # end

  # def header(text, header_level)
  #   text
  # end

  # def hrule
  # end

  def list(contents, list_type)
    "\n#{contents}"
  end

  def list_item(text, list_type)
    "• #{text.chomp}\n"
  end

  def paragraph(text)
    text + "\n\n"
  end

  # def table(header, body)
  # end

  # def table_row(content)
  # end

  # def table_cell(content, alignment, header)
  # end

  # def autolink(link, link_type)
  # end

  # def codespan(code)
  #   "`{#{code}}`"
  # end

  def double_emphasis(text)
    "<b>#{text}</b>"
  end

  def emphasis(text)
    "<i>#{text}</i>"
  end

  # def image(link, title, alt_text)
  # end

  # def linebreak
  # end

  # def link(link, title, content)
  # end

  # def raw_html(raw_html)
  # end

  def triple_emphasis(text)
    double_emphasis(emphasis(text))
  end

  def strikethrough(text)
    "<s>#{text}</s>"
  end

  # def superscript(text)
  # end

  def underline(text)
    "<u>#{text}</u>"
  end

  # def highlight(text)
  #   text
  # end

  # def quote(text)
  #   ">#{text}"
  # end

  # def footnote_ref(number)
  # end
end
