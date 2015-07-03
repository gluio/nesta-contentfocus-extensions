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

      def self.add_sass_path(path)
        Sass.load_paths << path
        SassPaths.append(path)
      end

      private
      def self.lock
        @lock || Mutex.new
      end
    end
  end
end

