require 'gemoji-parser'
require 'nesta-contentfocus-extensions/html_syntax_formatter'
module Nesta
  class Page < FileModel
    def convert_to_html(format, scope, text)
      text = add_p_tags_to_haml(text) if @format == :haml
      text = translate_emoji(text) if [:md, :mdown].include? @format
      template = Tilt[format].new(nil, 1, markdown_options) { text }
      template.render(scope)
    end

    def self.find_by_path(path, show_drafts = false)
      page = load(path)
      return page if show_drafts
      page && page.hidden? ? nil : page
    end

    def translate_emoji(text)
      EmojiParser.parse(text) { |emoji| emoji.raw  }
    end

    def authentication?
      return true if metadata('Passwords')
    end

    def passwords
      if metadata('Passwords')
        metadata('Passwords').split(',').map{ |p| p.strip }
      else
        []
      end
    end

    def intro_image
      return metadata('Intro Image') if metadata('Intro Image')
    end

    def intro_image_caption
      return metadata('Intro Image Caption') if metadata('Intro Image Caption')
    end

    def canonical_url
      return metadata('Canonical URL') if metadata('Canonical URL')
    end

    def markdown_options
      {
        auto_id_stripping: true,
        auto_ids: true,
        autolink: true,
        syntax_highlighter: :rouge,
        syntax_highlighter_opts: syntax_highlight_options,
        input: 'Nesta::ContentFocus::MarkdownParser'
      }
      # {
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
