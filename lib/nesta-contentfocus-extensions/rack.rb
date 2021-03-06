require 'sprockets'
require 'uglifier'
require 'sass'
require 'nesta-contentfocus-extensions/paths'
module Nesta
  module ContentFocus
    module Rack
      def self.mount_assets(context)
        context.instance_eval do
          map '/assets' do
            environment = Sprockets::Environment.new
            environment.js_compressor  = :uglify
            environment.css_compressor = :scss
            Nesta::ContentFocus::Paths.sass_paths.each do |path|
              environment.append_path path
            end
            Nesta::ContentFocus::Paths.javascript_paths.each do |path|
              environment.append_path path
            end
            run environment
          end
        end
      end
    end
  end
end
