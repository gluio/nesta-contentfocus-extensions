require 'sass_paths'
require 'nesta/env'
require 'nesta/path'
module Nesta
  module ContentFocus
    class Paths
      def self.public_paths
        lock.synchronize do
          @public_paths || []
        end
      end

      def self.view_paths
        lock.synchronize do
          @view_paths || []
        end
      end

      def self.javascript_paths
        lock.synchronize do
          @js_paths || []
        end
      end

      def self.sass_paths
        lock.synchronize do
          @sass_paths || []
        end
      end

      def self.add_public_path(path)
        lock.synchronize do
          @public_paths ||= []
          @public_paths.unshift(path)
        end
      end

      def self.add_view_path(path)
        lock.synchronize do
          @view_paths ||= []
          @view_paths.unshift(path)
        end
      end

      def self.add_js_path(path)
        lock.synchronize do
          @js_paths ||= []
          @js_paths.unshift(path)
        end
      end

      def self.add_sass_path(path)
        lock.synchronize do
          @sass_paths ||= []
          @sass_paths.unshift(path)
        end
        Sass.load_paths << path
        SassPaths.append(path)
      end

      def self.setup_base_app
        app_root = Nesta::Env.root
        asset_base = File.expand_path('../../assets', File.dirname(__FILE__))
        style_path = File.join(asset_base, 'stylesheets')
        js_path = File.join(asset_base, 'javascripts')
        add_sass_path(style_path)
        add_js_path(js_path)
        add_public_path(File.expand_path('public', app_root))
        add_view_path(File.expand_path('views', app_root))
        add_js_path(File.expand_path('public/javascripts', app_root))
        add_js_path(File.expand_path('views/javascripts', app_root))
      end

      def self.lock
        @lock || Mutex.new
      end
    end
  end
end
