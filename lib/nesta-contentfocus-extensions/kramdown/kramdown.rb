require 'net/http'
require 'yajl'

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

      def convert_s(el, indent)
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
        @span_parsers.unshift(:strikethrough)
        {:codeblock_fenced => :codeblock_fenced_gfm,
          :atx_header => :atx_header_gfm}.each do |current, replacement|
          i = @block_parsers.index(current)
          @block_parsers.delete(current)
          @block_parsers.insert(i, replacement)
        end
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

      ATX_HEADER_START = /^\#{1,6}\s/
      define_parser(:atx_header_gfm, ATX_HEADER_START, nil, 'parse_atx_header')

      FENCED_CODEBLOCK_MATCH = /^(([~`]){3,})\s*?(\w[\w-]*)?\s*?\n(.*?)^\1\2*\s*?\n/m
      define_parser(:codeblock_fenced_gfm, /^[~`]{3,}/, nil, 'parse_codeblock_fenced')

      STRIKETHROUGH_START = /~~/
      def parse_strikethrough
        start_line_number = @src.current_line_number
        @src.scan(STRIKETHROUGH_START)
        el = Element.new(:s, nil, nil, location: start_line_number)
        stop_re = /#{Regexp.escape("~~")}/
        parse_spans(el, stop_re) do
          (!@src.match?(/#{Regexp.escape("~~")}[[:alnum:]]/)) && el.children.size > 0
        end
        @src.scan(stop_re)
        @tree.children << el
      end
      define_parser(:strikethrough, STRIKETHROUGH_START, '~~')
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
        elsif el.attr['class'] == 'jobs'
          el.children.each do |li|
            build_jobs_to_be_done_layout(li)
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

      def build_jobs_to_be_done_layout(li)
        img = li.children.detect { |c| c.type == :img }
        li.children.delete(img)
        heading = li.children.detect { |c| c.type == :header }
        li.children.delete(heading)
        p = li.children.detect { |c| c.type == :p }
        li.children.delete(p)
        link = p.children.detect { |c| c.type == :a }
        p.children.delete(link)
        p.children += link.children
        children = []
        if img
          img_div = Element.new(:html_element, 'div', class: 'job-image')
          img_div.children << img
          childen << img_div
        end
        children << heading
        copy_div = Element.new(:html_element, 'div', class: 'copy')
        copy_div.children << p
        children << copy_div
        children.compact!
        link.children = children
        li.children = [link]
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
        if embedded_tweet?(el)
          add_embedded_tweet(el)
        else
          if %w(testimonial cited).include? el.attr['class']
            el.children.each do |child|
              next unless child.type == :p
              add_author_as_cite(child)
            end
          end
          pre_headstartup_convert_blockquote(el, indent)
        end
      end

      def embedded_tweet?(blockquote)
        return false unless blockquote.children.size == 1
        return false unless blockquote.children[0].type == :p
        paragraph = blockquote.children[0]
        return false unless paragraph.children.size == 1
        link = paragraph.children[0].attr['href']
        return false unless link =~ %r{\Ahttps://twitter\.com/.*/status/.*\z}
        true
      end

      def add_embedded_tweet(blockquote)
        paragraph = blockquote.children[0]
        link = paragraph.children[0].attr['href']
        url = URI.parse("https://api.twitter.com/1/statuses/oembed.json?omit_script=true&url=#{URI.encode(link)}")
        request = Net::HTTP::Get.new(url.request_uri)
        response = Net::HTTP.start(url.host, url.port, use_ssl: true ) { |http| http.request request }
        if response.code == "200"
          results = Yajl::Parser.parse(response.body)
          blockquote = results['html']
        end
      end

      def add_author_as_cite(paragraph)
        mdash_idx = paragraph.children.index { |c| mdash?(c) }
        return unless mdash_idx
        paragraph.children.delete_at(mdash_idx)
        el_count = paragraph.children.size
        cite = Element.new(:html_element, 'cite')
        children = paragraph.children.pop(el_count - mdash_idx)
        if children.first.type == :a && children.first.attr['href'] =~ /@/
          name = children.shift
          email = name.attr['href'].sub(/^mailto:/,'')
          hash = Digest::MD5.hexdigest(email)
          author = Element.new(:html_element, 'span', class: 'person')
          avatar = Element.new(:html_element, 'img', class: 'avatar', src: "//www.gravatar.com/avatar/#{hash}")
          author.children.push avatar
          author.children += name.children
          children.unshift(author)
        end
        cite.children = children
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
        byebug
        if type == :block && text
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
