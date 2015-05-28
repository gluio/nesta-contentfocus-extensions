require "nesta/path"

module Nesta
  class Path
    class << self
      alias_method :pre_contentfocus_themes, :themes
    end

    def self.themes(*args)
      theme = args[0]
      if Nesta::Config.theme && Nesta::Theme.const_defined?(theme.capitalize) && theme_dir = resolve_theme_path(theme)
        File.expand_path(File.join(*args[1..-1]), theme_dir + "/../..")
      else
        pre_contentfocus_themes(*args)
      end
    end

    def self.resolve_theme_path(theme)
      if path = $".grep(%r{nesta-theme-#{theme}\.rb})
        path.first
      end
    end
  end
end
