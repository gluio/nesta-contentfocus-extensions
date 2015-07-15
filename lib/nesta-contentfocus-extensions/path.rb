require 'nesta/path'
module Nesta
  class Path
    class << self
      alias_method :pre_contentfocus_themes, :themes
    end

    def self.themes(*args)
      theme = args[0]
      if theme_loaded?(theme) && theme_gemified?(theme)
        theme_dir = resolve_theme_path(theme)
        File.expand_path(File.join(*args[1..-1]), theme_dir + '/../..')
      else
        pre_contentfocus_themes(*args)
      end
    end

    def self.resolve_theme_path(theme)
      theme_gemified?(theme).first if theme_gemified?(theme)
    end

    def self.theme_gemified?(theme)
      $LOADED_FEATURES.grep(/nesta-theme-#{theme}\.rb/)
    end

    def self.theme_loaded?(theme)
      Nesta::Config.theme && Nesta::Theme.const_defined?(theme.capitalize)
    end
  end
end
