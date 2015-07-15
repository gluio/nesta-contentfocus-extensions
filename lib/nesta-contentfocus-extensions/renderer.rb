require 'pygments.rb'
require 'redcarpet'
require 'tilt'
module Nesta
  module ContentFocus
    class HTMLRenderer < Redcarpet::Render::HTML
      LANGUAGES = Pygments.lexers.map { |_, v| v[:aliases] }.flatten.sort

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
          ['<p>', content, '</p>'].join
        end
      end

      def block_code(code, language)
        @code_count ||= 0
        @code_count += 1
        code_block_id = "code-example-#{@code_count}"
        syntax_highlight(code, language, code_block_id)
      end

      def syntax_highlight_options(language, id)
        options = { options: {
          linenos: true,
          cssclass: 'hll',
          lineanchors: id,
          linespans: id,
          anchorlinenos: true
        } }
        options.merge!(lexer: language) if LANGUAGES.include? language
        options
      end

      def escape_example_codeblock(code)
        code.gsub(/^\\```/m, '```')
      end

      def escape_example_footnote(code)
        code.gsub(/^\\\[([a-z]+)/im, '[\1')
      end

      def syntax_highlight(code, language, id)
        options = syntax_highlight_options(language, id)
        code = escape_example_codeblock(code)
        code = escape_example_footnote(code)
        Pygments.highlight(code, options)
      end

      def block_quote(content)
        if content.match(/\A<p>\.([a-z]+) /)
          cssclass = $1
          content.sub!(/\A\<p>.([a-z]+) /, '')
          content.sub!(%r{</p>\z}, '')
          [%(<div class="#{cssclass}"><p>), content, '</p></div>'].join
        else
          ['<blockquote>', content, '</blockquote>'].join
        end
      end
    end
  end
end
