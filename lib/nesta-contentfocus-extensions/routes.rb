module Nesta
  module ContentFocus
    module Routes
      def self.included(app)
        app.instance_eval do
          get '/css/*.css' do
            content_type 'text/css', charset: 'utf-8'
            sheet = params[:splat].join('/')
            stylesheet(sheet.to_sym)
          end

          get '/login' do
            haml :login
          end

          get '*' do
            pass unless params.key?('draft')
            set_common_variables
            parts = params[:splat].map { |p| p.sub(/\/$/, '') }
            @page = Nesta::Page.find_by_path(File.join(parts), params.key?('draft'))
            raise Sinatra::NotFound if @page.nil?
            if @page.authentication? && !authenticated?(@page)
              session[:last_url] = request.fullpath
              redirect to('/login')
            else
              @title = @page.title
              set_from_page(:description, :keywords)
              haml(@page.template, layout: @page.layout)
            end
          end
        end
      end
    end
  end
end
