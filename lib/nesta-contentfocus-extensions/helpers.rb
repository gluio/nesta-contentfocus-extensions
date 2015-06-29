require 'nesta-contentfocus-extensions/paths'
module Nesta
  class App < Sinatra::Base
    helpers do
      def find_template(view_path, name, engine, &block)
        views = [view_path]
        views += Nesta::ContentFocus::Paths.view_paths
        views.each {|v| super(v, name, engine, &block) }
      end

      def body_class
        classes = [@body_class]
        if @page
          classes << "landing-page" if @page.flagged_as? "landing-page"
          classes << "bare" if @page.flagged_as? "sign-up"
        end
        classes.compact.sort.uniq.join(" ")
      end
    end
  end
end
