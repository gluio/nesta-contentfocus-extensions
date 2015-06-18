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
          @public_paths << path
        end
      end

      def self.add_view_path(path)
        lock.synchronize do
          @view_paths ||= []
          @view_paths << path
        end
      end

      private
      def self.lock
        @lock || Mutex.new
      end
    end
  end
end
Nesta::ContentFocus::Paths.add_view_path(Nesta::Path.local("public"))
Nesta::ContentFocus::Paths.add_public_path(Nesta::Path.local("views"))

