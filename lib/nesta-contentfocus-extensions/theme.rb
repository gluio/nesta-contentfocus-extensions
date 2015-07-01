require 'nesta-contentfocus-extensions/paths'
module Nesta
  module ContentFocus
    module Theme
      def register(name, paths = {})
        if paths[:base]
          base_path = paths[:base]
          view_path = File.expand_path(base_path + "/views")
          stylesheet_path = File.expand_path(base_path + "/stylesheets")
        end
        stylesheet_path = paths[:styles]
        view_path = paths[:views]
        if stylesheet_path
          Nesta::ContentFocus::Paths.add_sass_path(stylesheet_path)
          Nesta::ContentFocus::Paths.add_view_path(stylesheet_path)
        end
        if view_path
          Nesta::ContentFocus::Paths.add_view_path(view_path)
          Nesta::ContentFocus::Paths.add_view_path(File.expand_path(view_path + "/#{name}"))
        end
        if paths[:public]
        end
      end
    end
  end
end

module Nesta
  module Theme
    extend Nesta::ContentFocus::Theme
  end
end
