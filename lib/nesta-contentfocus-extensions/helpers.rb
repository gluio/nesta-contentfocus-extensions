require 'nesta-contentfocus-extensions/paths'
module Nesta
  class App < Sinatra::Base
    helpers do
      def authenticated?(page)
        return false if session[:passwords].nil? || session[:passwords].empty?
        page.passwords.detect do |password|
          session[:passwords].include? password
        end
      end

      def find_template(view_path, name, engine, &block)
        views = [view_path]
        views += Nesta::ContentFocus::Paths.view_paths
        views.each { |v| super(v, name, engine, &block) }
      end

      def body_class
        classes = [@body_class]
        if @page && @page.metadata('flags')
          classes += @page.metadata('flags').split(',')
          classes << 'bare' if @page.flagged_as? 'sign-up'
        end
        classes.compact.sort.uniq.join(' ')
      end

      def gravatar(email)
        if email
          hash = Digest::MD5.hexdigest(email.downcase)
          "//www.gravatar.com/avatar/#{hash}"
        end
      end
    end
  end
end
