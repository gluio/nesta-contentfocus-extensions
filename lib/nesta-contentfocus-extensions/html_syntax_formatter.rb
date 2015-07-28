require 'nesta-contentfocus-extensions/kramdown/kramdown'
module Nesta
  module ContentFocus
    class HTMLSyntaxFormatter < ::Rouge::Formatters::HTML

      def stream_tableized(tokens)
        num_lines = 0
        last_val = ''
        formatted = ''
        formatted << %Q{<span class="line" id="LC#{@start_line+num_lines}">}
        tokens.each do |tok, val|
          num_lines += val.scan(/\n/).size
          val.scan /\n|[^\n]+/ do |s|
            if s == "\n"
              formatted << %Q{</span>\n<span class="line" id="LC#{@start_line+num_lines}">}
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
          text = %Q{<a href="#L#{i}">#{i}</a>}
          numbers << %Q{<span class="line" id="L#{i}">#{text}</span>\n}
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
