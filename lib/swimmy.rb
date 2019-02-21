module Swimmy
  dir = File.dirname(__FILE__) + "/swimmy"

  autoload :App,                  "#{dir}/app.rb"
  autoload :Command,              "#{dir}/command.rb"
  autoload :Web,                  "#{dir}/web.rb"
  autoload :VERSION,              "#{dir}/version.rb"
end
