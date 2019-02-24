module Swimmy
  module Service
    dir = File.dirname(__FILE__) + "/service"

    autoload :Geocoding,   "#{dir}/geocoding.rb"
    autoload :Weather,     "#{dir}/weather.rb"
  end
end
