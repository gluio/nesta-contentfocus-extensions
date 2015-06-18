require 'sinatra/flash'
require 'nesta/app'
module Nesta
  class App
    register Sinatra::Flash
  end
end
