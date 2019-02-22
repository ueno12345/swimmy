module Swimmy
  module Command
    dir = File.dirname(__FILE__) + "/command"

    require "#{dir}/base.rb"

    Dir.glob(File.expand_path("*.rb", dir)).each do |rb|
      require rb
    end
  end
end
