require 'sinatra/flash'
require 'nesta-contentfocus-extensions/routes'
require 'nesta/app'
module Nesta
  class App
    register Sinatra::Flash
    include Nesta::ContentFocus::Routes
  end
end
