require 'nesta-contentfocus-extensions/kramdown'
module Nesta
  module ContentFocus
    class HTMLRenderer < Kramdown::Document

      def preprocess(document)
        @document = document
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
        #options.merge!(lexer: language) if LANGUAGES.include? language
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

    end
  end
end
