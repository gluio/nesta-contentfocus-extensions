require 'pygments.rb'
require 'redcarpet'
require 'tilt'
require 'nesta/models'

module Nesta
  module ContentFocus
    class HTMLRenderer < Redcarpet::Render::HTML
      LANGUAGES = Pygments.lexers.map{|k,v| v[:aliases]}.flatten.sort

      def preprocess(document)
        @document = document
      end

      def paragraph(content)
        if ['[TOC]'].include?(content)
          toc_render = Redcarpet::Render::HTML_TOC.new(nesting_level: 2)
          parser     = Redcarpet::Markdown.new(toc_render)
          rendered = parser.render(@document)
          rendered.sub!(/\A<ul>/, '<ul class="toc">')
          return rendered
        else
          ["<p>",content,"</p>"].join
        end
      end

      def block_code(code, language)
        options = {options: {
          linenos: true,
          cssclass: "hll",
          anchorlinenos: true
        }}
        options.merge!(lexer: language) if LANGUAGES.include? language
        highlighted_code = Pygments.highlight(code, options)
        highlighted_code
      end

      def block_quote(content)
        if content.match(/\A<p>\.([a-z]+) /)
          cssclass = $1
          content.sub!(/\A\<p>.([a-z]+) /, "")
          content.sub!(/<\/p>\z/, "")
          [%Q{<div class="#{cssclass}"><p>}, content, "</p></div>"].join
        else
          ["<blockquote>", content, "</blockquote>"].join
        end
      end
    end
  end
end

module Nesta
  class Page < FileModel
    def convert_to_html(format, scope, text)
      render_options = {
        safe_links_only: true,
        with_toc_data: true
      }
      markdown_options = {
        renderer: Nesta::ContentFocus::HTMLRenderer.new(render_options),
        autolink: true,
        disable_indented_code_blocks: true,
        fenced_code_blocks: true,
        footnotes: true,
        highlight: true,
        no_intra_emphasis: true,
        quote: true,
        strikethrough: true,
        superscript: true,
        tables: true
      }
      text = add_p_tags_to_haml(text) if @format == :haml
      template = Tilt[format].new(nil, 1, markdown_options) { text }
      template.render(scope)
    end

    def intro_image
      return metadata('Intro Image') if metadata('Intro Image')
    end
  end
end
