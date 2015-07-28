require 'nesta-contentfocus-extensions/kramdown/kramdown'
module Nesta
  module ContentFocus
    class HTMLSyntaxFormatter < ::Rouge::Formatters::HTML
      attr_reader :block_id

      def initialize(opts = {})
        @block_id = opts.fetch(:block_id, "")
        super(opts)
      end

      def stream_tableized(tokens)
        num_lines = 0
        last_val = ''
        formatted = ''
        line_closed = true
        tokens.each do |tok, val|
          num_lines += val.scan(/\n/).size
          val.scan /\n|[^\n]+/ do |s|
            if line_closed
              line_id = ["LC", block_id, (@start_line+num_lines)].join
              formatted << %Q{<span class="line" id="#{line_id}">}
              line_closed = false
            end
            if s == "\n"
              formatted << %Q{</span>\n}
              line_closed = true
            else
              span(tok, s) { |str| formatted << str }
            end
          end
          last_val = val
        end
        formatted << '</span>'

        # add an extra line for non-newline-terminated strings
        if last_val[-1] != "\n"
          num_lines += 1
          span(Token::Tokens::Text::Whitespace, "\n") { |str| formatted << str }
        end

        numbers = '<pre class="lineno">'
        (@start_line..num_lines+@start_line-1).to_a.map do |i|
          line_id = ["L", block_id, i].join
          text = %Q{<a href="##{line_id}">#{i}</a>}
          numbers << %Q{<span class="line" id="#{line_id}">#{text}</span>\n}
        end
        numbers << '</pre>'

        yield "<div#@css_class>" if @wrap
        yield '<table style="border-spacing: 0"><tbody><tr>'

        # the "gl" class applies the style for Generic.Lineno
        yield '<td class="gutter gl" style="text-align: right">'
        yield numbers
        yield '</td>'

        yield '<td class="code">'
        yield '<pre>'
        yield formatted
        yield '</pre>'
        yield '</td>'

        yield "</tr></tbody></table>\n"
        yield "</div>\n" if @wrap
      end
    end
  end
end
