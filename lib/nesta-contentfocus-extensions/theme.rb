require 'nesta-contentfocus-extensions/paths'
module Nesta
  module ContentFocus
    module Theme
      def register(name, paths = {})
        if paths[:base]
          base_path = paths[:base]
          view_path = File.expand_path(base_path + '/views')
          stylesheet_path = File.expand_path(base_path + '/stylesheets')
        end
        stylesheet_path = paths[:styles] if paths[:styles]
        view_path = paths[:views] if paths[:views]
        register_style_path(stylesheet_path)
        register_view_path(name, view_path)
      end

      def register_style_path(path)
        return unless path
        Paths.add_sass_path(path)
        Paths.add_view_path(path)
      end

      def register_js_path(path)
        return unless path
        Paths.add_js_path(path)
      end

      def register_view_path(name, path)
        return unless path
        Paths.add_view_path(path)
        Paths.add_view_path(File.expand_path(path + "/#{name}"))
      end
    end
  end
end

module Nesta
  module Theme
    extend Nesta::ContentFocus::Theme
  end
end
