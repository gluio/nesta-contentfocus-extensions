require 'nesta-contentfocus-extensions/kramdown/kramdown'
require 'nesta-contentfocus-extensions/rouge/formatters/html'
module Nesta
  module ContentFocus
    class HTMLSyntaxFormatter < ::Rouge::Formatters::HTML
    end
  end
end
