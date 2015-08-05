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
      return @full_menu unless @full_menu.empty?
      @full_menu = write_new_menu(categories)
    end

    def self.categories
      return @categories if @categories
      @categories = Page.find_all.map(&:categories).flatten.compact.uniq
      @categories.sort_by!(&:abspath)
      @categories
    end

    def self.write_new_menu(categories)
      menu = []
      with_menu_file do |menu_file|
        categories.each do |category|
          write_category_to_menu(category, menu_file)
        end
        menu_file.rewind
        append_menu_item(menu, menu_file, 0)
      end
      menu
    end

    def self.write_category_to_menu(category, file, indent = '')
      category_path = category.abspath
      file.write(indent + category_path + "\n")
      category.pages.each do |sub_category|
        write_category_to_menu(sub_category, file, Nesta::Menu::INDENT)
      end
    end

    def self.with_menu_file
      menu_file = File.open(Nesta::Config.content_path('menu.txt'), 'w+')
      yield menu_file
      menu_file.close
    end
  end
end
