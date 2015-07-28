require 'rouge'
require 'rouge/formatters/html_linewise'
require 'kramdown'
require 'kramdown/converter'
require 'tilt'
require 'nesta/models'

Tilt.register Tilt::KramdownTemplate, 'markdown', 'mkd', 'md'
Tilt.prefer Tilt::KramdownTemplate

module Kramdown
  module SyntaxHighlighter
    module Rouge
      def self.call(converter, text, lang, type, _unused_opts)
        opts = converter.options[:syntax_highlighter_opts].dup
        lexer = ::Rouge::Lexer.find_fancy(lang || opts[:default_lang], text)
        return nil unless lexer
        if type == :span
          opts[:wrap] = false
          opts[:line_numbers] = false
        end
        formatter = (opts.delete(:formatter) || ::Rouge::Formatters::HTML).new(opts)
        formatter.format(lexer.lex(text))
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

      def convert_ul(el, indent)
        if ['benefits', 'how', 'features'].include? el.attr['class']
          el.children.each do |li|
            p = li.children.detect{ |c| c.type == :p }
            if p
              img = p.children.detect{ |c| c.type == :img}
              if img
                description = Element.new(:html_element, 'div', :class => 'description')
                example = Element.new(:html_element, 'div', :class => 'example')
                p.children.delete(img)
                example.children = [img]
                description.children = li.children
                li.children = [example, description]
              end
            end
          end
        end
        output = pre_headstartup_convert_ul(el, indent)
        output
      end

      def convert_blockquote(el, indent)
        if ['testimonial', 'cited'].include? el.attr['class']
          p = el.children.detect{ |c| c.type == :p }
          if p
            mdash_idx = p.children.index{ |c| c.type == :typographic_sym && c.value == :mdash }
            if mdash_idx
              next_el = p.children[mdash_idx + 1]
              p.children.delete_at(mdash_idx)
              cite = Element.new(:html_element, 'cite')
              cite.children = p.children.pop(p.children.size - mdash_idx)
              p.children.push cite
            end
          end
        end
        output = pre_headstartup_convert_blockquote(el, indent)
      end

      def convert_header(el, indent)
        output = pre_headstartup_convert_header(el, indent)
        matched, open, content, close = *output.match(%r{(.*<h[1-6][^>]*>)(.*)(</h[1-6]>)})
        split_content = content.split(' ')
        if split_content.size > 3
          split_content[-1] = [split_content[-2], '&nbsp;', split_content.pop].join
          content = split_content.join(' ')
        end
        [open, content, close].join
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
