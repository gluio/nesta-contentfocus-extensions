require 'nesta-contentfocus-extensions/renderer'
module Nesta
  class Page < FileModel
    def convert_to_html(format, scope, text)
      text = add_p_tags_to_haml(text) if @format == :haml
      STDOUT.puts markdown_options
      template = Tilt[format].new(nil, 1, markdown_options) { text }
      template.render(scope)
    end

    def intro_image
      return metadata('Intro Image') if metadata('Intro Image')
    end

    def markdown_options
      {
        autolink: true,
        disable_indented_code_blocks: true,
        fenced_code_blocks: true,
        footnotes: true,
        highlight: true,
        no_intra_emphasis: true,
        quote: true,
        strikethrough: true,
        syntax_highlighter: :rouge,
        superscript: true,
        tables: true }
    end
  end
end
