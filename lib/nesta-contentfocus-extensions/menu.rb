require 'tempfile'
require 'tilt'
require 'nesta/models'

module Nesta
  class Menu
    class << self
      alias_method :pre_contentfocus_full_menu, :full_menu
    end

    def self.full_menu
      return @full_menu if @full_menu
      @full_menu = pre_contentfocus_full_menu
      if @full_menu.empty?
        menu_file = Tempfile.new('menu')
        categories = Page.find_all.map(&:categories).flatten.compact.uniq
        categories.sort!(&:abspath)
        categories.each do |category|
          menu_file.write(category.abspath + "\n")
          category.pages.each do |sub_category|
            menu_file.write(Nesta::Menu::INDENT + sub_category.abspath + "\n")
          end
        end.flatten
        menu_file.rewind
        append_menu_item(@full_menu, menu_file, 0)
        menu_file.close
        menu_file.unlink
      end
      @full_menu
    end
  end
end
