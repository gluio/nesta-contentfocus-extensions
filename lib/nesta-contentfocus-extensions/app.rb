require 'sinatra/flash'
require 'nesta-contentfocus-extensions/routes'
module Nesta
  class App < Sinatra::Base
    register Sinatra::Flash
    include Nesta::ContentFocus::Routes
  end
end
