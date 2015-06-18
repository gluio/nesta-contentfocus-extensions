require 'nesta/overrides'
module Nesta
  module Overrides
    private
    def self.render_options(template, *engines)
      Nesta::ContentFocus::Paths.public_paths.each do |path|
        engines.each do |engine|
          if template_exists?(engine, path, template)
            return { views: path }, engine
          end
        end
      end
      [{}, :sass]
    end
  end
end
