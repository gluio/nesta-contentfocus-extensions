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

          get '*' do
            set_common_variables
            parts = params[:splat].map { |p| p.sub(/\/$/, '') }
            @page = Nesta::Page.find_by_path(File.join(parts), params[:draft])
            raise Sinatra::NotFound if @page.nil?
            @title = @page.title
            set_from_page(:description, :keywords)
            haml(@page.template, layout: @page.layout)
          end
        end
      end
    end
  end
end
