module Swimmy
  module Resource
    dir = File.dirname(__FILE__) + "/resource"

    autoload :Place,       "#{dir}/place.rb"
    autoload :Weather,     "#{dir}/weather.rb"
  end
end
