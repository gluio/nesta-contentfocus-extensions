module Nesta
  module ContentFocus
    module Routes
      def self.included(app)
        app.instance_eval do
          get '/css/*.css' do
            STDOUT.puts "Debugging: #{params.inspect}"
            content_type 'text/css', charset: 'utf-8'
            sheet = params[:splat].join("/")
            stylesheet(sheet.to_sym)
          end
        end
      end
    end
  end
end
