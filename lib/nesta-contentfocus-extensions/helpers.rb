require 'nesta/app'
module Nesta
  class App
    helpers do
      def body_class
        classes = [@body_class]
        if @page
          classes << "landing-page" if @page.flagged_as? "landing-page"
          classes << "bare" if @page.flagged_as? "sign-up"
        end
        classes.sort.uniq.join(" ")
      end
    end
  end
end
