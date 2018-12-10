require 'sinatra/base'

module Swimmy
  class Web < Sinatra::Base
    get '/' do
      "swimmy"
    end
  end
end