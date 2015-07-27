require 'rouge/formatters/html'
module Rouge
  module Formatters
    class HTML < Formatter
      alias_method :pre_contentfocus_span, :span
      def span(tok, val)
        output = pre_contentfocus_span(tok, val)
        if @line_numbers
          yield ['<span class="line">', output, '</span>'].join
        else
          yield output
        end
      end
    end
  end
end
