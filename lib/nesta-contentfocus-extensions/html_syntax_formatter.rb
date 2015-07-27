require 'nesta-contentfocus-extensions/kramdown/kramdown'
require 'nesta-contentfocus-extensions/rouge/formatters/html'
module Nesta
  module ContentFocus
    class HTMLSyntaxFormatter < ::Rouge::Formatters::HTML
      attr_reader :options

      def initialize(opts = {})
        super(opts)
        @options = opts
      end

      def stream(tokens, &blk)
        yield '<span class="line">'
        tokens.each do |tok, val|
          val.scan /\n|[^\n]+/ do |s|
            if s == "\n"
              yield %Q{</span>\n<span class="line">}
            else
              yield span(tok, s)
            end
          end
        end
        yield "</span>"
      end
    end
  end
end
