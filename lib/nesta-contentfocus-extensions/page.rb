require 'nesta-contentfocus-extensions/html_syntax_formatter'
module Nesta
  class Page < FileModel
    def convert_to_html(format, scope, text)
      text = add_p_tags_to_haml(text) if @format == :haml
      template = Tilt[format].new(nil, 1, markdown_options) { text }
      template.render(scope)
    end

    def intro_image
      return metadata('Intro Image') if metadata('Intro Image')
    end

    def markdown_options
      {
        auto_id_stripping: true,
        auto_ids: true,
        autolink: true,
        syntax_highlighter: :rouge,
        syntax_highlighter_opts: syntax_highlight_options
      }
      #{
      #  autolink: true,
      #  highlight: true,
      #  no_intra_emphasis: true,
      #  quote: true,
      #  strikethrough: true,
      #  superscript: true,
    end

    def syntax_highlight_options
      {
        line_numbers: true,
        css_class: 'hll',
        formatter: Nesta::ContentFocus::HTMLSyntaxFormatter
      }
    end
  end
end
