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

          get '/robots.txt' do
            content_type 'text/plain', charset: 'utf-8'
            <<-EOF
# robots.txt
# See http://en.wikipedia.org/wiki/Robots_exclusion_standard
            EOF
          end

          get '/articles.xml' do
            content_type :xml, charset: 'utf-8'
            set_from_config(:title, :subtitle, :author)
            @articles = Page.find_articles.select { |a| a.date }[0..9]
            haml(:atom, format: :xhtml, layout: false)
          end

          get '/sitemap.xml' do
            content_type :xml, charset: 'utf-8'
            @pages = Page.find_all.reject do |page|
              page.draft? or page.flagged_as?('skip-sitemap')
            end
            @last = @pages.map { |page| page.last_modified }.inject do |latest, page|
              (page > latest) ? page : latest
            end
            haml(:sitemap, format: :xhtml, layout: false)
          end

          get '*' do
            pass unless params.key?('draft')
            set_common_variables
            parts = params[:splat].map { |p| p.sub(/\/$/, '') }
            @page = Nesta::Page.find_by_path(File.join(parts), params.key?('draft'))
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
