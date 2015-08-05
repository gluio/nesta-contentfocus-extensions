require 'digest/sha1'
require 'rouge'
require 'rouge/formatters/html_linewise'
require 'kramdown'
require 'kramdown/converter'
require 'tilt'
require 'nesta/models'

Tilt.register Tilt::KramdownTemplate, 'markdown', 'mkd', 'md'
Tilt.prefer Tilt::KramdownTemplate

module Kramdown
  module Converter
    class Html < Base
      def convert_mark(el, indent)
        format_as_span_html(el.type, el.attr, inner(el, indent))
      end
    end
  end
end

require 'kramdown/parser/kramdown'
module Nesta
  module ContentFocus
    class MarkdownParser < Kramdown::Parser::Kramdown
      def initialize(source, options)
        super
        @span_parsers.unshift(:highlight)
      end

      HIGHLIGHT_START = /(?:==?)/

      def parse_highlight
        start_line_number = @src.current_line_number
        @src.scan(HIGHLIGHT_START)
        el = Element.new(:mark, nil, nil, location: start_line_number)
        stop_re = /#{Regexp.escape("==")}/
        parse_spans(el, stop_re) do
          (!@src.match?(/#{Regexp.escape("==")}[[:alnum:]]/)) && el.children.size > 0
        end
        @src.scan(stop_re)
        @tree.children << el
      end
      define_parser(:highlight, HIGHLIGHT_START, '==')


      GFM_ATX_HEADER_START = /^\#{1,6}\s/
      define_parser(:atx_header_gfm, GFM_ATX_HEADER_START, nil, 'parse_gfm_atx_header')

      GFM_FENCED_CODEBLOCK_MATCH = /^(([~`]){3,})\s*?(\w[\w-]*)?\s*?\n(.*?)^\1\2*\s*?\n/m
      def parse_gfm_codeblock_fenced
        if @src.check(self.class::GFM_FENCED_CODEBLOCK_MATCH)
          start_line_number = @src.current_line_number
          @src.pos += @src.matched_size
          el = new_block_el(:codeblock, @src[4], nil, :location => start_line_number)
          lang = @src[3].to_s.strip
          el.attr['class'] = "language-#{lang}" unless lang.empty?
          @tree.children << el
          true
        else
          false
        end
      end
      define_parser(:codeblock_fenced_gfm, /^[~`]{3,}/, nil, 'parse_gfm_codeblock_fenced')
    end
  end
end

module Kramdown
  module SyntaxHighlighter
    module Rouge
      def self.call(converter, text, lang, type, block_opts)
        opts = build_options(converter, type, block_opts)
        lexer = ::Rouge::Lexer.find_fancy(lang || opts[:default_lang], text)
        return nil unless lexer
        format_klass = (opts.delete(:formatter) || ::Rouge::Formatters::HTML)
        formatter = format_klass.new(opts)
        formatter.format(lexer.lex(text))
      end

      def self.build_options(converter, type, block_opts)
        opts = converter.options[:syntax_highlighter_opts].dup
        opts.merge!(block_opts)
        if type == :span
          opts[:wrap] = false
          opts[:line_numbers] = false
        end
        opts
      end
    end
  end

  module Converter
    add_syntax_highlighter :rouge do |converter, text, lang, type, opts|
      add_syntax_highlighter :rouge, ::Kramdown::SyntaxHighlighter::Rouge
      syntax_highlighter(:rouge).call(converter, text, lang, type, opts)
    end

    class Html < Base
      alias_method :pre_headstartup_convert_ul, :convert_ul
      alias_method :pre_headstartup_convert_blockquote, :convert_blockquote
      alias_method :pre_headstartup_convert_header, :convert_header
      alias_method :pre_headstartup_convert_highlight_code, :highlight_code

      def convert_ul(el, indent)
        if %w(benefits how features).include? el.attr['class']
          el.children.each do |li|
            build_product_layout(li)
          end
        end
        pre_headstartup_convert_ul(el, indent)
      end

      def build_product_layout(li)
        p = li.children.detect { |c| c.type == :p }
        return unless p
        img = p.children.detect { |c| c.type == :img }
        return unless img
        example = extract_example(p, img)
        description = extract_description(li)
        li.children = [example, description]
      end

      def extract_description(li)
        description = Element.new(:html_element, 'div', class: 'description')
        description.children = li.children
        description
      end

      def extract_example(p, img)
        example = Element.new(:html_element, 'div', class: 'example')
        p.children.delete(img)
        example.children = [img]
        example
      end

      def mdash?(el)
        el.type == :typographic_sym && el.value == :mdash
      end

      def convert_blockquote(el, indent)
        if %w(testimonial cited).include? el.attr['class']
          p = el.children.detect { |c| c.type == :p }
          add_author_as_cite(p) if p
        end
        pre_headstartup_convert_blockquote(el, indent)
      end

      def add_author_as_cite(paragraph)
        mdash_idx = paragraph.children.index { |c| mdash?(c) }
        return unless mdash_idx
        el_count = paragraph.children.size
        paragraph.children.delete_at(mdash_idx)
        cite = Element.new(:html_element, 'cite')
        cite.children = paragraph.children.pop(el_count - mdash_idx)
        paragraph.children.push cite
      end

      def convert_header(el, indent)
        output = pre_headstartup_convert_header(el, indent)
        heading_regex = %r{(.*<h[1-6][^>]*>)(.*)(</h[1-6]>)}
        _, open, content, close = *output.match(heading_regex)
        split_content = content.split(' ')
        if split_content.size > 3
          joined_words = [split_content[-2], '&nbsp;', split_content.pop].join
          split_content[-1] = joined_words
          content = split_content.join(' ')
        end
        [open, content, close].join
      end

      def highlight_code(text, lang, type, opts = {})
        if type == :block
          opts[:block_id] = "-#{Digest::SHA1.hexdigest(text)[0...6]}-"
        end
        pre_headstartup_convert_highlight_code(text, lang, type, opts)
      end
    end

    #  def block_code(code, language)
    #    @code_count ||= 0
    #    @code_count += 1
    #    code_block_id = "code-example-#{@code_count}"
    #    syntax_highlight(code, language, code_block_id)
    #  end

    #  def syntax_highlight_options(language, id)
    #    options = { options: {
    #      linenos: true,
    #      cssclass: 'hll',
    #      lineanchors: id,
    #      linespans: id,
    #      anchorlinenos: true
    #    } }
    #    #options.merge!(lexer: language) if LANGUAGES.include? language
    #    options
    #  end
  end
end
